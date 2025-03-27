import AVFoundation
import Combine
import ComposableArchitecture
import CoreImage
import ExtensionKit
import Foundation
import OrientationClient
import Pipeline
import Preferences
import Shared
import Shopfront
import UIKit

public final class LiveAVCaptureClient: NSObject,
AVCaptureClient,
AVCaptureAudioDataOutputSampleBufferDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate,
AVCapturePhotoCaptureDelegate,
AVCaptureMetadataOutputObjectsDelegate,
RecorderDelegate
{

	// MARK: - Substructures
	
	private struct CapturingMetadata {
		let aspectRatio: AspectRatio
		let orientation: UIDeviceOrientation
		let position: AVCaptureDevice.Position
		let transformation: Transformation
	}
	
	// MARK: Properties (Publishers)
	
	public var activeDevicePositionPublisher: AnyPublisher<AVCaptureDevice.Position, Never> {
		activeDevicePositionSubject
			.subscribe(on: sessionQueue)
			.eraseToAnyPublisher()
	}
	
	public var constituentDevicePublisher: AnyPublisher<ZoomLevelDisplayable?, Never> {
		constituentDeviceSubject.eraseToAnyPublisher()
	}
	
	public var captureLifecyclePublisher: AnyPublisher<CaptureLifecycle, Never> {
		captureLifecycleSubject
			.subscribe(on: sessionQueue)
			.eraseToAnyPublisher()
	}
	
	public var statePublisher: AnyPublisher<SessionState, Never> {
		stateSubject
			.subscribe(on: sessionQueue)
			.eraseToAnyPublisher()
	}
	
	public var capturedImagePublisher: AnyPublisher<AVCapturedImage, Never> {
		capturedImageSubject.eraseToAnyPublisher()
	}
	
	public var previewImagePublisher: AnyPublisher<AVPreviewImage, Never> {
		previewImageSubject.eraseToAnyPublisher()
	}
	
	public var redactedPreviewImagePublisher: AnyPublisher<AVPreviewImage, Never> {
		redactedImageSubject.eraseToAnyPublisher()
	}
	
	public var qrCodesPublisher: AnyPublisher<AVMetadataMachineReadableCodeObject, Never> {
		qrCodesSubject
			.subscribe(on: metadataOutputQueue)
			.eraseToAnyPublisher()
	}
	
	// MARK: - Properties (Publisher Subjects)
	
	private let activeDevicePositionSubject: CurrentValueSubject<AVCaptureDevice.Position, Never>
	private let captureLifecycleSubject = CurrentValueSubject<CaptureLifecycle, Never>(.idle)
	private let constituentDeviceSubject: CurrentValueSubject<ZoomLevelDisplayable?, Never>
	private let stateSubject = CurrentValueSubject<SessionState, Never>(.idle)
	private let capturedImageSubject = PassthroughSubject<AVCapturedImage, Never>()
	private let previewImageSubject = PassthroughSubject<AVPreviewImage, Never>()
	private let redactedImageSubject = PassthroughSubject<AVPreviewImage, Never>()
	private let qrCodesSubject = PassthroughSubject<AVMetadataMachineReadableCodeObject, Never>()
	
	// MARK: - Properties (State and Transformations)
	
	public var aspectRatio: AspectRatio
	public var isAttemptingToRun: Bool = false
	public var isRunning: Bool {
		stateSubject.value == .running
	}
	
	private var cancellables = Set<AnyCancellable>()
	private var captures: [Int64: CapturingMetadata] = [:]
	private let context: CIContext
	private var hasAddedIO = false
	private var hasAmendedZoomValue = false
	private var motionTrackedOrientation = UIDeviceOrientation.portrait
	private var position: AVCaptureDevice.Position {
		currentDevice?.position ?? .front
	}
	private let preferredLaunchPosition: AVCaptureDevice.Position
	private var preferredFlashMode: AVCaptureDevice.FlashMode
	private var recorder: Recorder?
	private var transformation: Transformation
	
	private var constituentDeviceZoomCancellable: AnyCancellable?
	
	// MARK: - Properties (Queues)
	
	private let sessionQueue = DispatchQueue(
		label: "com.eff.corp.aperture.capture.DefaultCaptureSession.sessionQueue",
		qos: .default
	)
	private let dataOutputQueue = DispatchQueue(
		label: "com.eff.corp.aperture.capture.DefaultCaptureSession.DataOutputQueue",
		qos: .default
	)
	private let metadataOutputQueue = DispatchQueue(
		label: "com.eff.corp.aperture.capture.DefaultCaptureSession.MetadataOutputQueue",
		qos: .default
	)
	
	private let bufferTransformationQueue = DispatchQueue(
		label: "com.eff.corp.aperture.capture.DefaultCaptureSession.BufferTransformationQueue",
		qos: .userInitiated
	)
	
	private let photoCaptureTransformationQueue = DispatchQueue(
		label: "com.eff.corp.aperture.capture.DefaultCaptureSession.photoCaptureTransformationQueue",
		qos: .userInitiated
	)

	// MARK: - Session Management
	
	private var audioSessionErrorTicks = Int(0)
	private static var errorTicksLimit = Int(10)
	
	// MARK: - Properties (Session && IO)
	
	private let session: AVCaptureSession = {
		let session = AVCaptureSession()
		session.automaticallyConfiguresApplicationAudioSession = false
		if session.canSetSessionPreset(.photo) { session.sessionPreset = .photo }
		else if session.canSetSessionPreset(.hd1280x720) { session.sessionPreset = .hd1280x720 }
		return session
	}()
	private let frontFacingWideValue: Double = 1.0
	private let frontFacingTightValue: Double = 1.2
	
	private var audioDataOutput: AVCaptureAudioDataOutput?
	private var captureConnection: AVCaptureConnection?
	private var currentDevice: AVCaptureDevice?
	private let metadataQRCodesOutput = AVCaptureMetadataOutput()
	private var photoCaptureOutput = AVCapturePhotoOutput()
	private var photoCaptureSettings: AVCapturePhotoSettings {
		let settings = AVCapturePhotoSettings(
			format: [
				AVVideoCodecKey: AVVideoCodecType.jpeg,
			]
		)
		settings.isHighResolutionPhotoEnabled = true
		
		if photoCaptureOutput.supportedFlashModes.contains(preferredFlashMode) {
			settings.flashMode = preferredFlashMode
		}
		return settings
	}
	private var videoInput: AVCaptureDeviceInput?
	private var videoDataOutput: AVCaptureVideoDataOutput?
	
	public var availableZoomFactors: [NSNumber] {
		guard let currentDevice else { return [] }
		
		if currentDevice.position == .back {
			return currentDevice.virtualDeviceSwitchOverVideoZoomFactors
		}
		else {
			return [
				.init(value: frontFacingWideValue),
				.init(value: frontFacingTightValue)
			]
		}
	}
	
	@Dependency(\.mainQueue) var mainQueue
	@Dependency(\.shopfrontClient) var shopfrontClient
	@Dependency(\.preferencesClient) var preferencesClient
	
	// MARK: Lifecycle
	
	public init(
		context: CIContext,
		preferences: PreferencesClient
	) {
		self.activeDevicePositionSubject = .init(.unspecified)
		self.constituentDeviceSubject = .init(nil)
		
		self.aspectRatio = preferences.preferredAspectRatio
		self.preferredLaunchPosition = preferences.preferredLaunchDevicePosition
		self.preferredFlashMode = preferences.preferredFlashMode
		self.transformation = .init(
			preferences.preferredGrainPresence,
			preferences.preferredQuantization
		)
		self.context = context
		super.init()
		OrientationClient.shared.startMeasuring()
		
		OrientationClient.shared
			.deviceOrientationPublisher
			.sink { orientation in
				self.motionTrackedOrientation = orientation
			}
			.store(in: &cancellables)
		
		photoCaptureOutput.isHighResolutionCaptureEnabled = true
		if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
			setup(position: preferredLaunchPosition)
		}
		
		addObservers()
		
		statePublisher
			.receive(on: mainQueue)
			.sink { state in
//				UIApplication.shared.isIdleTimerDisabled = state == .running
			}
			.store(in: &cancellables)
	}

	public func setup(position: AVCaptureDevice.Position) {
		func setupSession() throws {
			removeAllSessionIO()
			try addIO(position: position)
		}
		
		let videoMediaType: AVMediaType = .video
		switch AVCaptureDevice.authorizationStatus(for: videoMediaType) {
		case .authorized: break
			
		case .notDetermined:
			sessionQueue.suspend()
			AVCaptureDevice.requestAccess(for: videoMediaType) { [weak self] isAuthorized in
				if !isAuthorized { self?.stateSubject.send(.notAuthorized) }
				self?.sessionQueue.resume()
			}
			
		case .denied, .restricted:
			stateSubject.send(.notAuthorized)
			return
			
		@unknown default:
			stateSubject.send(.notAuthorized)
			return
		}
		
		sessionQueue.async {
			do {
				self.stateSubject.send(.idle)
				if !self.hasAddedIO { try setupSession() }
				self.stateSubject.send(.success)
			} catch let error {
				assertionFailure(error.localizedDescription)
				self.stateSubject.send(.error(error as NSError, false))
			}
		}
	}
	
	private func addObservers() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(captureSessionRuntimeError),
			name: .AVCaptureSessionRuntimeError,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(captureSessionRuntimeError),
			name: .AVCaptureSessionRuntimeError,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(captureSessionRuntimeError),
			name: .AVCaptureSessionWasInterrupted,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(captureSessionInterruptionEnded),
			name: .AVCaptureSessionInterruptionEnded,
			object: nil
		)
	}
	
	private func removeObservers() {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	// MARK: - IO Manipulation
	
	public func setupMicrophoneIO() {
		#warning("Currently returning early because the launch of the video recording is still up in the air.")
		guard false else { return }
		
		sessionQueue.async { [weak self] in
			guard
				let self = self,
				let microphone = AVCaptureDevice.default(for: .audio),
				AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
			else { return }
			
			self.session.beginConfiguration()
			defer { self.session.commitConfiguration() }
				
			do {
				let microphoneDeviceInput = try AVCaptureDeviceInput(device: microphone)
				guard self.session.canAddInput(microphoneDeviceInput) else { return }
				self.session.addInput(microphoneDeviceInput)
				
				/// Disable the added audio port to ensure we don't interrupt audio playback from other apps.
				self.disableAudioPort()
			} catch { return }
			
			self.audioDataOutput?.setSampleBufferDelegate(nil, queue: nil)
			let microphoneAudioDataOutput = AVCaptureAudioDataOutput()
			guard self.session.canAddOutput(microphoneAudioDataOutput) else { return }
			self.session.addOutput(microphoneAudioDataOutput)
			microphoneAudioDataOutput.setSampleBufferDelegate(self, queue: self.dataOutputQueue)
			self.audioDataOutput = microphoneAudioDataOutput
		}
	}
	
	private func addIO(position: AVCaptureDevice.Position) throws {
		sessionQueue.async { [weak self] in
			guard let self = self else { return }
			
			func cleanupAndThrow(_ error: NSError, _ canRetry: Bool) {
				self.stateSubject.send(.error(error, canRetry))
				self.session.commitConfiguration()
			}
			
			do {
				self.session.beginConfiguration()
				
				let device: AVCaptureDevice?
				
//				if position == .front {
//					device = AVCaptureDevice.default(
//						.builtInTrueDepthCamera,
//						for: .video,
//						position: position
//					) ?? AVCaptureDevice.default(
//						.builtInDualCamera,
//						for: .video,
//						position: position
//					)
//					?? AVCaptureDevice.default(
//						.builtInWideAngleCamera,
//						for: .video,
//						position: position
//					)
//				}
//				else {
//					device = AVCaptureDevice.default(
//						.builtInTripleCamera,
//						for: .video,
//						position: position
//					)
//					?? AVCaptureDevice.default(
//						.builtInDualWideCamera,
//						for: .video,
//						position: position
//					)
//					?? AVCaptureDevice.default(
//						.builtInDualCamera,
//						for: .video,
//						position: position
//					)
//					?? AVCaptureDevice.default(
//						.builtInWideAngleCamera,
//						for: .video,
//						position: position
//					)
//				}

				#warning("Override the device selection to be the fixed lens.")
				device = AVCaptureDevice.default(
					.builtInWideAngleCamera,
					for: .video,
					position: position
				)
				
				guard let captureDevice = device else {
					cleanupAndThrow(SessionError.missingVideoDevice as NSError, false)
					return
				}
				
				self.currentDevice = device
				
				let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
				self.videoInput = deviceInput
				
				guard self.session.canAddInput(deviceInput) else {
					cleanupAndThrow(SessionError.invalidCaptureInput as NSError, false)
					return
				}
				
				self.session.addInputWithNoConnections(deviceInput)
				
				guard let port = deviceInput.ports.first else {
					cleanupAndThrow(
						SessionError.invalidCaptureInput as NSError,
						false
					)
					return
				}
				
				self.videoDataOutput?.setSampleBufferDelegate(nil, queue: nil)
				let videoDataOutput = AVCaptureVideoDataOutput()
				videoDataOutput.setSampleBufferDelegate(self, queue: self.dataOutputQueue)
				videoDataOutput.alwaysDiscardsLateVideoFrames = true
				videoDataOutput.automaticallyConfiguresOutputBufferDimensions = false
				videoDataOutput.deliversPreviewSizedOutputBuffers = true
				
				guard self.session.canAddOutput(videoDataOutput) else {
					cleanupAndThrow(SessionError.invalidCaptureOutput as NSError, false)
					return
				}
				self.session.addOutputWithNoConnections(videoDataOutput)
				self.videoDataOutput = videoDataOutput
				
				let dataConnection = AVCaptureConnection(inputPorts: [port], output: videoDataOutput)
				if dataConnection.isVideoOrientationSupported {
					dataConnection.videoOrientation = .portrait
				}
				if dataConnection.isVideoMirroringSupported {
					dataConnection.isVideoMirrored = position == .front
				}
				
				guard self.session.canAddConnection(dataConnection) else {
					cleanupAndThrow(SessionError.unableToAddDataConnection as NSError, false)
					return
				}
				self.session.addConnection(dataConnection)
				self.captureConnection = dataConnection
				
				guard self.session.canAddOutput(self.photoCaptureOutput) else {
					cleanupAndThrow(SessionError.invalidCaptureOutput as NSError, false)
					return
				}
				self.session.addOutput(self.photoCaptureOutput)

				if let photoOutputConnection = self.photoCaptureOutput.connection(with: .video) {
					photoOutputConnection.videoOrientation = dataConnection.videoOrientation
				}

				setupMicrophoneIO()
					
				do {
					try captureDevice.lockForConfiguration()
					if captureDevice.position == .front {
						captureDevice.videoZoomFactor = .init(preferencesClient.lastKnownFrontFacingZoomValue)
					}
					else {
						captureDevice.videoZoomFactor = .init(preferencesClient.lastKnownBackFacingZoomValue)
					}
					captureDevice.unlockForConfiguration()
				}
				catch _ { }
				
				self.session.commitConfiguration()
				self.hasAddedIO = true

//				self.constituentDeviceZoomCancellable = captureDevice
//					.publisher(for: \.videoZoomFactor)
//					.sink { [weak self] zoomFactor in
//						guard
//							let self = self
//						else { return }
//
//						if captureDevice.position == .front {
//							if zoomFactor == frontFacingWideValue { constituentDeviceSubject.send(.string("0.5")) }
//							else { constituentDeviceSubject.send(.string("1.0")) }
//							preferencesClient.setlastKnownFrontFacingZoomValue(Float(zoomFactor))
//						}
//						else {
//							var availableZooms = availableZoomFactors
//							let constDevices = captureDevice.constituentDevices
//
//							func readableFromDevice(_ device: AVCaptureDevice) -> String {
//								switch captureDevice.deviceType {
//								case .builtInTripleCamera:
//									switch device.deviceType {
//									case .builtInUltraWideCamera: return "0.5"
//									case .builtInWideAngleCamera: return "1.0"
//									case .builtInTelephotoCamera: return "3.0"
//									default: return ""
//									}
//
//								case .builtInDualCamera:
//									switch device.deviceType {
//									case .builtInUltraWideCamera: return "1.0"
//									case .builtInWideAngleCamera: return "1.0"
//									case .builtInTelephotoCamera: return "2.0"
//									default: return ""
//									}
//								default: return ""
//								}
//
//							}
//
//							if !constDevices.isEmpty {
//								if zoomFactor == 1, let device = constDevices.first {
//									constituentDeviceSubject.send(.string(readableFromDevice(device)))
//								}
//								else if availableZooms.contains(where: { $0.floatValue.isEqual(to: .init(zoomFactor)) }) {
//									availableZooms.insert(1, at: 0)
//									if let deviceIndex = availableZooms.firstIndex(of: .init(floatLiteral: zoomFactor)), constDevices.indices.contains(deviceIndex) {
//										let unwrappedDevice = constDevices[deviceIndex]
//										constituentDeviceSubject.send(.string(readableFromDevice(unwrappedDevice)))
//									}
//								}
//							}
//
//							preferencesClient.setlastKnownBackFacingZoomValue(Float(zoomFactor))
//						}
//					}
				
			} catch let error {
				self.hasAddedIO = false
				cleanupAndThrow(error as NSError, false)
			}
		}
	}
	
	private func removeAllSessionIO() {
		sessionQueue.async {
			self.hasAddedIO = false
			self.session.inputs.forEach(self.session.removeInput)
			self.session.outputs.forEach(self.session.removeOutput)
			self.session.connections.forEach(self.session.removeConnection)
		}
	}
	
	private func disableAudioPort() {
		for deviceInputs in self.session.inputs.filter({ $0.ports.contains { $0.mediaType == .audio } }) {
			for port in deviceInputs.ports.filter({ $0.mediaType == .audio }) {
				port.isEnabled = false
			}
		}
	}
	
	private func enableAudioPort() {
		for deviceInputs in self.session.inputs.filter({ $0.ports.contains { $0.mediaType == .audio } }) {
			for port in deviceInputs.ports.filter({ $0.mediaType == .audio }) {
				port.isEnabled = true
			}
		}
	}
	
	
	// MARK: - Notifications
	
	@objc private func captureSessionRuntimeError(_ notification: Notification) {
		guard
			let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError
		else { return }
		
		if stateSubject.value == .success || stateSubject.value == .running, audioSessionErrorTicks < Self.errorTicksLimit {
			startCaptureSession(transformation)
		} else {
			isAttemptingToRun = false
			stateSubject.send(.error(error as NSError, true))
		}
	}
	
	@objc private func captureSessionInterruptionEnded(_ notification: NSNotification) {
		startCaptureSession(transformation)
		stateSubject.send(.running)
	}
	
	
	// MARK: - Photos
	
	public func capture() {
		#if !targetEnvironment(simulator)
		guard
			!photoCaptureOutput.connections.isEmpty
		else { return }
		
		photoCaptureOutput.capturePhoto(
			with: photoCaptureSettings,
			delegate: self
		)
		#endif
	}
	
	
	// MARK: - Power State
	
	public func startCaptureSession(_ transformations: Transformation) {
		if !hasAddedIO { setup(position: position) }
		
		self.isAttemptingToRun = true

		sessionQueue.async {
			self.transformation = transformations
			guard !self.session.isRunning else { return }
			self.disableAudioPort()
			self.session.startRunning()
			if self.session.isRunning { self.stateSubject.send(.running) }
		}
	}
	
	public func stopCaptureSession() {
		sessionQueue.async {
			guard self.session.isRunning else { return }
			self.isAttemptingToRun = false
			self.session.stopRunning()
			self.stateSubject.send(.success)
		}
	}

	
	// MARK: - QR Codes
	
	public func startTrackingQRCodes() {
		sessionQueue.async { [weak self] in
			guard
				let self = self,
				self.session.canAddOutput(self.metadataQRCodesOutput)
			else { return }
			
			self.session.addOutput(self.metadataQRCodesOutput)
			
			guard
				self.metadataQRCodesOutput.availableMetadataObjectTypes.contains(.qr)
			else { return }
			
			self.metadataQRCodesOutput.setMetadataObjectsDelegate(
				self,
				queue: self.metadataOutputQueue
			)
			self.metadataQRCodesOutput.metadataObjectTypes = [.qr]
		}
	}
	
	public func stopTrackingQRCodes() {
		sessionQueue.async { [weak self] in
			guard
				let self = self,
				self.session.outputs.contains(self.metadataQRCodesOutput)
			else { return }
			self.session.removeOutput(self.metadataQRCodesOutput)
		}
	}
	
	
	// MARK: - Transformation
	
	public func flushBuffer() {
		previewImageSubject.send(.init(rawValue: nil))
	}
	
	public func setAspectRatio(_ newValue: AspectRatio) {
		aspectRatio = newValue
	}
	
	public func setCameraPosition(_ position: AVCaptureDevice.Position) {
		sessionQueue.async { [weak self] in
			guard let self = self else { return }
			if self.position != position {
				self.session.beginConfiguration()
				self.removeAllSessionIO()
				try? self.addIO(position: position)
				self.session.commitConfiguration()
			}
		}
	}
	
	public func toggleCamera() {
		sessionQueue.async { [weak self] in
			guard let self = self else { return }
			let flippedPosition: AVCaptureDevice.Position = self.position == .front ? .back : .front
			self.session.beginConfiguration()
			self.removeAllSessionIO()
			try? self.addIO(position: flippedPosition)
			self.session.commitConfiguration()
			self.activeDevicePositionSubject.send(flippedPosition)
		}
	}
	
	public func toggleFlashMode() -> AVCaptureDevice.FlashMode {
		let next = preferredFlashMode.next()
		if photoCaptureOutput.supportedFlashModes.contains(next) {
			preferredFlashMode = next
			return next
		}
		return preferredFlashMode
	}
	
	public func updateTransformation(_ transformation: Transformation) {
		sessionQueue.async { [weak self] in self?.transformation = transformation }
	}
	
	
	// MARK: - Video
	
	public func cancelRecordingVideo() {
		recorder = nil
		self.disableAudioPort()
	}
	
	public func startRecordingVideo(
		url: URL
	) throws {
		enableAudioPort()
		
		let fileType = AVFileType.mp4
		guard
			let videoSettings = videoDataOutput?.recommendedVideoSettingsForAssetWriter(
				writingTo: fileType
			)
		else {
			throw CaptureError.failedToGenerateSettingsForAssetWriter
		}
		
		let width: CGFloat = (videoSettings[AVVideoWidthKey] as? CGFloat) ?? UIScreen.main.bounds.width
		
		let size = CGSize(
			width: width * aspectRatio.portrait.width,
			height: width * aspectRatio.portrait.height
		)
		
		let new = Recorder(
			audioSettings: audioDataOutput?.recommendedAudioSettingsForAssetWriter(
				writingTo: fileType
			),
			videoSettings: videoSettings,
			videoTransform: .identity
		)
		new.startRecording(fileURL: url, fileType: fileType, size: size)
		new.delegate = self
		recorder = new
	}
	
	public func stopRecordingVideo() async throws -> URL {
		guard let recorder = recorder else { throw SessionError.invalidRecordingState }
		let url = try await recorder.stopRecording()
		self.disableAudioPort()
		return url
	}
	
	
	// MARK: - Focus
	
	public func setFocus(_ point: CGPoint) {
		guard let currentDevice else { return }

		do {
			let amended = CGPoint(
				x: abs(point.y),
				y: abs(1 - point.x)
			)
			
			try currentDevice.lockForConfiguration()
			
			if currentDevice.isFocusPointOfInterestSupported {
				currentDevice.focusPointOfInterest = amended
				currentDevice.focusMode = .autoFocus
			}
			
			if currentDevice.isExposurePointOfInterestSupported {
				currentDevice.exposurePointOfInterest = amended
				currentDevice.exposureMode = .autoExpose
			}
			
			currentDevice.focusMode = .continuousAutoFocus
			currentDevice.exposureMode = .continuousAutoExposure
			
			currentDevice.unlockForConfiguration()
		}
		catch { }
	}
	
	
	// MARK: - Zoom

	public func rampToNext(_ direction: ZoomDirection) -> Bool {
		guard let currentDevice else { return false }
		let currentZoomFactor = currentDevice.videoZoomFactor

		if currentDevice.position == .front {
			if currentDevice.videoZoomFactor == frontFacingWideValue, direction == .tighter {
				rampToZoomFactor(frontFacingTightValue)
				return true
			}
			else if currentDevice.videoZoomFactor != frontFacingWideValue, direction == .wider {
				rampToZoomFactor(frontFacingWideValue)
				return true
			}
			return false
		}
		else {
			guard !availableZoomFactors.isEmpty else { return false }
			
			if direction == .tighter, let nextBiggerValue = availableZoomFactors.first(where: { CGFloat($0.floatValue) > currentZoomFactor }) {
				rampToZoomFactor(.init(nextBiggerValue.floatValue))
				return true
			}
			else if direction == .wider, let nextSmallerValue = availableZoomFactors.last(where: { CGFloat($0.floatValue) < currentZoomFactor }) {
				rampToZoomFactor(.init(nextSmallerValue.floatValue))
				return true
			}
			else if direction == .wider {
				rampToZoomFactor(1.0)
				return true
			}
			return false
		}
	}
	
	public func resetZoomFactor() {
		updateZoomFactor(low: 1.0, high: 1.0)
		hasAmendedZoomValue = false
	}
	
	public func updateZoomFactor(low: CGFloat, high: CGFloat) {
		guard
			let currentDevice = currentDevice
		else { return }
		
		hasAmendedZoomValue = true
		
		do {
			try currentDevice.lockForConfiguration()
			var zoomFactor = (low - high) / 50
			
			if (zoomFactor < 1) {
				zoomFactor = 1
			}
			else if zoomFactor > currentDevice.maxAvailableVideoZoomFactor {
				zoomFactor = currentDevice.maxAvailableVideoZoomFactor
			}
			
			currentDevice.videoZoomFactor = zoomFactor
			currentDevice.unlockForConfiguration()
		}
		catch { }
	}
	
	private func rampToZoomFactor(_ zoomFactor: CGFloat) {
		guard let currentDevice else { return }
		
		do {
			try currentDevice.lockForConfiguration()
			
			var zoomFactor = zoomFactor
			
			if (zoomFactor < 1) {
				zoomFactor = 1
			}
			else if zoomFactor > currentDevice.maxAvailableVideoZoomFactor {
				zoomFactor = currentDevice.maxAvailableVideoZoomFactor
			}
			
			currentDevice.videoZoomFactor = zoomFactor

			currentDevice.unlockForConfiguration()
		}
		catch { }
		
		
		if currentDevice.position == .back {
			let target = currentDevice.videoZoomFactor
			
			let foo = currentDevice
				.constituentDevices
				.min(by: { abs($0.videoZoomFactor - target) < abs($1.videoZoomFactor - target) })
		}
		else {
			
		}
	}
	
	// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
	
	public func captureOutput(
		_ output: AVCaptureOutput,
		didOutput sampleBuffer: CMSampleBuffer,
		from connection: AVCaptureConnection
	) {
		bufferTransformationQueue.async {
			if let recorder = self.recorder, recorder.isRecording, output == self.audioDataOutput {
				recorder.recordAudio(sampleBuffer: sampleBuffer)
				return
			}

			guard
				let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
			else { return }
			let ciimage = CIImage(cvImageBuffer: imageBuffer, options: [.applyOrientationProperty : false])
			
			let converted = convert(
				img: ciimage,
				aspectRatio: self.aspectRatio,
				context: self.context,
				position: self.position,
				transformation: self.transformation
			)
			
			if
				let recorder = self.recorder,
				recorder.isRecording,
				let convertedBuffer = converted?.cgImage?.sampleBuffer(
					timingInfo: CMSampleTimingInfo(
						duration: sampleBuffer.duration,
						presentationTimeStamp: sampleBuffer.presentationTimeStamp,
						decodeTimeStamp: sampleBuffer.decodeTimeStamp
					)
				)
			{
					recorder.recordVideo(sampleBuffer: convertedBuffer)
			}
			
			self.previewImageSubject.send(.init(rawValue: converted))
			
			Task {
				guard
					self.transformation.preferredQuantization.isProtectedByIAP,
					try await self.shopfrontClient.hasActiveSubscription() == false,
					let converted,
					let redactedCI = CIImage(image: converted)
				else { return }
	
				let (redactedImage, _) = redact(redactedCI, self.context)
				
				await MainActor.run {
					self.redactedImageSubject.send(.init(rawValue: redactedImage))
				}
			}
		}
	}
	
	
	// MARK: - AVCapturePhotoCaptureDelegate
	
	public func photoOutput(
		_ output: AVCapturePhotoOutput,
		willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings
	) {
		captureLifecycleSubject.send(.willBeginCapture(resolvedSettings.uniqueID))
	}
	
	public func photoOutput(
		_ output: AVCapturePhotoOutput,
		willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
	) {
		captureLifecycleSubject.send(.willCapture(resolvedSettings.uniqueID))
	}
	
	public func photoOutput(
		_ output: AVCapturePhotoOutput,
		didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
	) {
		self.captures[resolvedSettings.uniqueID] = .init(
			aspectRatio: aspectRatio,
			orientation: motionTrackedOrientation,
			position: position,
			transformation: transformation
		)
		captureLifecycleSubject.send(.didCapture(resolvedSettings.uniqueID))
	}
	
	public func photoOutput(
		_ output: AVCapturePhotoOutput,
		didFinishProcessingPhoto photo: AVCapturePhoto,
		error: Error?
	) {
		guard
			let settings = captures[photo.resolvedSettings.uniqueID]
		else { return }
		
		let transformation = settings.transformation
		
		photoCaptureTransformationQueue.async { [weak self] in
			guard
				let self,
				let data = photo.fileDataRepresentation(),
				let ci = CIImage.init(data: data, options: [.applyOrientationProperty: true]),
				let img = convert(
					img: ci,
					aspectRatio: settings.aspectRatio,
					context: self.context,
					position: settings.position,
					transformation: settings.transformation
				),
				let data = img.jpegData(compressionQuality: 1.0)
			else { return }
			
			if let enriched = MetadataEnricher.enrich(
				data,
				photo.metadata,
				settings.orientation,
				settings.position,
				.init(
					grain: transformation.preferredGrainPresence,
					quantization: transformation.preferredQuantization
				)
			),
				 let createdCI = CIImage(data: enriched, options: [.applyOrientationProperty: true])
			{
				self.capturedImageSubject.send(
					.init(
						identifier: photo.resolvedSettings.uniqueID,
						pixelWidth: .init(createdCI.extent.width),
						pixelHeight: .init(createdCI.extent.height),
						position: settings.position,
						rawValue: enriched
					)
				)
			}
			else if let createdCI = CIImage(data: data, options: [.applyOrientationProperty: true]) {
				self.capturedImageSubject.send(
					.init(
						identifier: photo.resolvedSettings.uniqueID,
						pixelWidth: .init(createdCI.extent.width),
						pixelHeight: .init(createdCI.extent.height),
						position: settings.position,
						rawValue: data
					)
				)
			}
		}
	}
	
	public func photoOutput(
		_ output: AVCapturePhotoOutput,
		didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
		error: Error?
	) {
		captureLifecycleSubject.send(.idle)
	}
	
	
	// MARK: - AVCaptureMetadataOutputObjectsDelegate
	
	public func metadataOutput(
		_ output: AVCaptureMetadataOutput,
		didOutput metadataObjects: [AVMetadataObject],
		from connection: AVCaptureConnection
	) {
		guard
			let readable = metadataObjects.first as? AVMetadataMachineReadableCodeObject
		else { return }
		qrCodesSubject.send(readable)
	}
	
	// MARK: - RecorderDelegate
	
	public func recorderDidBeginRecording(_ recorder: Recorder) {
		guard captureLifecycleSubject.value != .willBeginRecording else { return }
		captureLifecycleSubject.send(.willBeginRecording)
	}
	
	public func recorderDidFinishRecording(_ recorder: Recorder) {
		guard captureLifecycleSubject.value != .idle else { return }
		captureLifecycleSubject.send(.idle)
	}
	
	public func recorderDidUpdateRecordingDuration(
		_ recorder: Recorder,
		duration: Measurement<UnitDuration>
	) {
		captureLifecycleSubject.send(.recording(duration))
	}
}

extension AVCaptureDevice.FlashMode: Equatable, CaseIterable {
	public static var allCases: [AVCaptureDevice.FlashMode] {
		[
			.off,
			.auto,
			.on
		]
	}
}

extension Array where Element: (Comparable & SignedNumeric) {
		func nearest(to value: Element) -> (offset: Int, element: Element)? {
				self.enumerated().min(by: {
						abs($0.element - value) < abs($1.element - value)
				})
		}
}
