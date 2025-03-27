import AVFoundation
import Foundation
import SwiftUI

public struct VideoView: View {
	let url: URL
	let isPlaying: Bool
	let isMuted: Bool
	
	@State private var playbackProgress = Float(0)
	
	public init(
		url: URL,
		isPlaying: Bool,
		isMuted: Bool
	) {
		self.url = url
		self.isPlaying = isPlaying
		self.isMuted = isMuted
	}
	
	public var body: some View {
		ZStack {
			PlayerView(
				url: url,
				isPlaying: isPlaying,
				isMuted: isMuted,
				onPlaybackProgressChange: { progress in playbackProgress = progress }
			)
			
			Color.clear
				.preference(key: PlaybackProgressKey.self, value: playbackProgress)
		}
	}
}

struct PlayerView: UIViewRepresentable {
	let url: URL
	let isPlaying: Bool
	let isMuted: Bool
	
	let onPlaybackProgressChange: (Float) -> Void
	
	public func makeUIView(context: Context) -> AVPlayerView {
		AVPlayerView(
			url: url,
			isPlaying: isPlaying,
			isMuted: isMuted,
			onPlaybackStatusChange: { _ in },
			onPlaybackProgressChange: { progress in
				onPlaybackProgressChange(progress)
			}
		)
	}
	
	public func updateUIView(_ playerView: AVPlayerView, context: Context) {
		playerView.setIsMuted(isMuted)
		playerView.setIsPlaying(isPlaying)
	}
}

public class AVPlayerView: UIView {
	private let onPlaybackStatusChange: (Bool) -> Void
	private let playerLayer = AVPlayerLayer()
	private var playbackStatusObserver: NSKeyValueObservation?
	
	private var playbackProgressObserver: Any?
	private let onPlaybackProgressChange: (Float) -> Void
	private let player = AVPlayer(playerItem: nil)
	private var progress = Float(0)
	private var displayLink: CADisplayLink?
	
	private var wasPlayingBeforeAVCaptureSessionInterruption = false
	private var isCaptureSessionActive = false
	
	init(
		url: URL,
		isPlaying: Bool,
		isMuted: Bool,
		onPlaybackStatusChange: @escaping (Bool) -> Void,
		onPlaybackProgressChange: @escaping (Float) -> Void
	) {
		self.onPlaybackStatusChange = onPlaybackStatusChange
		self.onPlaybackProgressChange = onPlaybackProgressChange
		
		super.init(frame: .zero)
		
		let item = AVPlayerItem(url: url)
		self.playbackStatusObserver = item.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
			self?.updateStatus(item.status, animated: true)
		}
		
		player.replaceCurrentItem(with: item)
		player.actionAtItemEnd = .none
		
		playerLayer.player = player
		playerLayer.contentsGravity = .resizeAspectFill
		playerLayer.videoGravity = .resizeAspectFill
		
		setIsMuted(isMuted)
		setIsPlaying(isPlaying)
		updateStatus(item.status, animated: false)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(playerItemEnded),
			name: .AVPlayerItemDidPlayToEndTime,
			object: player.currentItem
		)
		
		layer.addSublayer(playerLayer)
	}
	
	func addPeriodicTimeObserver() {
		let timeScale = CMTimeScale(NSEC_PER_SEC)
		let time = CMTime(seconds: 0.02, preferredTimescale: timeScale)
		
		playbackProgressObserver = player.addPeriodicTimeObserver(
			forInterval: time,
			queue: .global(qos: .userInteractive)
		) { [weak self] time in self?.handlePlaybackProgressTime(time) }
		
		displayLink?.invalidate()
		displayLink = CADisplayLink(
			target: self,
			selector: #selector(handleDisplayLinkRefresh)
		)
		displayLink?.add(to: .main, forMode: .common)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit { removePeriodicTimeObserver() }
	
	override public func layoutSubviews() {
		super.layoutSubviews()
		playerLayer.frame = bounds
		playerLayer.removeAllAnimations()
	}
	
	public override func removeFromSuperview() {
		super.removeFromSuperview()
		displayLink?.invalidate()
	}
	
	@objc private func playerItemEnded(notification: Notification) {
		guard let playerItem = notification.object as? AVPlayerItem else { return }
		
		playerItem.seek(to: .zero, completionHandler: nil)
	}
	
	@objc private func handleAVCaptureSessionBeginNotification(_ notification: Notification) {
		guard player.timeControlStatus == .playing || player.timeControlStatus == .waitingToPlayAtSpecifiedRate else { return }
		isCaptureSessionActive = true
		wasPlayingBeforeAVCaptureSessionInterruption = true
		setIsPlaying(false, seekToZero: false)
	}
	
	@objc private func handleAVCaptureSessionEndNotification(_ notification: Notification) {
		guard wasPlayingBeforeAVCaptureSessionInterruption else { return }
		isCaptureSessionActive = false
		setIsPlaying(true)
	}
	
	func setIsMuted(_ isMuted: Bool) {
		guard playerLayer.player?.isMuted != isMuted else { return }
		playerLayer.player?.isMuted = isMuted
	}
	
	func setIsPlaying(_ isPlaying: Bool, seekToZero: Bool = true) {
		if isPlaying {
			guard
				!isCaptureSessionActive, player.timeControlStatus == .paused
			else { return }
			
			playerLayer.player?.play()
		} else {
			playerLayer.player?.pause()
			guard seekToZero else { return }
			playerLayer.player?.currentItem?.seek(to: .zero, completionHandler: nil)
		}
	}
	
	func updateStatus(_ status:  AVPlayerItem.Status, animated: Bool) {
		DispatchQueue.main.async {
			switch status {
			case .readyToPlay:
				self.onPlaybackStatusChange(true)
				self.addPeriodicTimeObserver()
			default:
				self.onPlaybackStatusChange(false)
				self.removePeriodicTimeObserver()
			}
		}
	}
	
	private func handlePlaybackProgressTime(_ time: CMTime) {
		guard let duration = player.currentItem?.asset.duration else { return }
		progress = Float(time.seconds / duration.seconds)
	}
	
	private func removePeriodicTimeObserver() {
		displayLink?.invalidate()
		
		if let timeObserverToken = playbackProgressObserver {
			player.removeTimeObserver(timeObserverToken)
			playbackProgressObserver = nil
		}
	}
	
	@objc func handleDisplayLinkRefresh() {
		onPlaybackProgressChange(progress)
	}
}

public struct PlaybackProgressKey: PreferenceKey {
	static public var defaultValue: Float = 0
	static public func reduce(value: inout Float, nextValue: () -> Float) { value = nextValue() }
}
