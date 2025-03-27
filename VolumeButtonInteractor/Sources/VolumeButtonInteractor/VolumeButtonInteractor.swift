import AVFoundation
import Foundation
import MediaPlayer

public final class VolumeButtonHandler: NSObject {
	
	// MARK: - Types
	
	private enum Constants {
		static let maxVolume: Float = 0.99
		static let minVolume: Float = 0.01
	}
	
	/// Which button is pressed
	public enum Button {
		/// Up or increase the volume
		case up
		/// Down or decrease the volume
		case down
	}
	
	public typealias ButtonHandler = (Button) -> Void
	
	
	// MARK: - Public properties
	
	/// The closure for handle the button clicks
	public var buttonClosure: ButtonHandler?
	
	/// This flag indicates whether audio session observation is running.
	public private(set) var isStarted: Bool = false
	
	
	// MARK: - Private properties
	
	private var appIsActive: Bool = true
	private var initialVolume: Float = 0
	private var session: AVAudioSession?
	private var sessionCategory: AVAudioSession.Category = .playAndRecord
	private var sessionOptions: AVAudioSession.CategoryOptions = [.mixWithOthers, .allowBluetoothA2DP, .defaultToSpeaker]
	private var sessionObservation: NSKeyValueObservation?
	private var volumeView: MPVolumeView
	
	
	// MARK: - Init
	
	/// - Parameters:
	///   - containerView: The UIView for placing hidden MPVolumeView instance
	///   - buttonClosure: The closure for handle button clicks
	public init(containerView: UIView, buttonClosure: ButtonHandler? = nil) {
		self.buttonClosure = buttonClosure
		self.volumeView = MPVolumeView(frame: CGRect(x: -100, y: -100, width: 0, height: 0))
		super.init()
		containerView.addSubview(volumeView)
		containerView.sendSubviewToBack(volumeView)
		volumeView.alpha = 0.01
	}
	
	deinit {
		stop()
		volumeView.removeFromSuperview()
	}
	
	
	// MARK: - Public methods
	
	/// Start volume button handling
	public func start() {
		setupSession()
	}
	
	/// Stop volume button handling
	public func stop() {
		guard isStarted else { return }
		sessionObservation = nil
		try? session?.setActive(false)
		session = nil
		NotificationCenter.default.removeObserver(self)
		isStarted = false
	}
	
	
	// MARK: - Private methods
	
	func setupSession() {
		guard !isStarted else { return }
		isStarted = true
		
		session = AVAudioSession.sharedInstance()
		// this must be done before calling setCategory or else the initial volume is reset
		setInitialVolume()
		do {
			try session?.setCategory(sessionCategory, options: sessionOptions)
			try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
			try session?.setActive(true)
		} catch {
			logEvent("Can't start audio session\n\(error)", .audioSession)
			return
		}
		
		// Observe outputVolume
		sessionObservation = session?.observe(
			\.outputVolume,
			 options: [.old, .new],
			 changeHandler: { [weak self] (session, change) in
				 self?.handleVolumeChange(change)
			 }
		)
		
		// Audio session is interrupted when you send the app to the background,
		// and needs to be set to active again when it goes to app goes back to the foreground
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(audioSessionInterrupted(_:)),
			name: AVAudioSession.interruptionNotification,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(applicationDidChangeActive(_:)),
			name:
				UIApplication.willResignActiveNotification,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(applicationDidChangeActive(_:)),
			name: UIApplication.didBecomeActiveNotification,
			object: nil)
	}
	
	private func setInitialVolume() {
		guard let session = session else { return }
		initialVolume = session.outputVolume
		logEvent("Initial volume \(initialVolume)", .audioSession)
		if initialVolume > Constants.maxVolume {
			initialVolume = Constants.maxVolume
			setSystemVolume(initialVolume)
		} else if initialVolume < Constants.minVolume {
			initialVolume = Constants.minVolume
			setSystemVolume(initialVolume)
		}
	}
	
	@objc
	private func audioSessionInterrupted(_ notification: Notification?) {
		guard
			let interuptionDict = notification?.userInfo,
			let rawInteruptionType = interuptionDict[AVAudioSessionInterruptionTypeKey] as? UInt,
			let interuptionType = AVAudioSession.InterruptionType(rawValue: rawInteruptionType)
		else {
			return
		}
		switch interuptionType {
		case .began:
			logEvent("Audio Session Interruption case started.", .audioSession)
		case .ended:
			logEvent("Audio Session Interruption case ended.", .audioSession)
			try? session?.setActive(true)
		default:
			logEvent("Audio Session Interruption Notification case default.", .audioSession)
		}
	}
	
	@objc
	private func applicationDidChangeActive(_ notification: Notification?) {
		guard let ntfName = notification?.name else { return }
		appIsActive = ntfName == UIApplication.didBecomeActiveNotification
		if appIsActive && isStarted {
			setInitialVolume()
		}
	}
	
	private func setSystemVolume(_ volume: Float) {
		//find the volumeSlider
		let volumeViewSlider = volumeView.subviews.first { $0 is UISlider } as? UISlider
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
			volumeViewSlider?.value = volume
		}
	}
	
	private func handleVolumeChange(_ change: NSKeyValueObservedChange<Float>) {
		guard self.appIsActive else { return }
		let oldVolume = change.oldValue ?? 0
		let newVolume = change.newValue ?? 0
		
		if newVolume == initialVolume {
			// Resetting volume, skip blocks
			return
		}
		
		let difference = fabsf(newVolume - oldVolume)
		logEvent("Old vol: \(oldVolume), new vol: \(newVolume), diff: \(difference)", .audioSession)
		
		if newVolume > oldVolume {
			// Up
			buttonClosure?(.up)
		} else {
			// Down
			buttonClosure?(.down)
		}
		
		// Reset volume to initial value
		setSystemVolume(initialVolume)
	}
}
