import AVCaptureClient
import AVFoundation
import ComposableArchitecture
import Foundation
import LocationClient
import PermissionsClient
import Pipeline
import Preferences
import Shared
import Shopfront
import Shoebox
import UIKit

public struct CameraFeature: ReducerProtocol {
	
	public struct State: Equatable {
		public var screen: Screen
		public var cameraPermission: PermissionState?
		public var cameraPermissionsNotGranted: Bool {
			cameraPermission != .allowed
		}
		public var transformation: Transformation
		public var shouldShowCameraButton: Bool {
			shutterStyle == .dedicatedButton
		}

		public var isCurrentQuantizationRestricted = false
		public internal(set) var pendingRestrictedQuantizationCapture: Data?
		
		public internal(set) var preferredAspectRatio: AspectRatio
		public internal(set) var preferredFlashMode: AVCaptureDevice.FlashMode
		public internal(set) var preferredQuantization: Quantization
		public internal(set) var preferredGrainPresence: GrainPresence
		
		public internal(set) var shouldReverseCameraControls: Bool
		public internal(set) var shutterStyle = ShutterStyle.dedicatedButton
		
		public internal(set) var zoomLevelDisplayable: ZoomLevelDisplayable?
		
		public internal(set) var captureFlashFired = false
		public internal(set) var captureLifecycle = CaptureLifecycle.idle
		
		internal var hasLoadedPipeline = false
		
		public mutating func setNeedsUpdateQuantizationRestriction() {
			isCurrentQuantizationRestricted = preferredQuantization.isProtectedByIAP && ShopfrontClient.shared.hasActiveSubscription == false
		}
		
		public init(
			cameraPosition: AVCaptureDevice.Position,
			preferredAspectRatio: AspectRatio,
			preferredFlashMode: AVCaptureDevice.FlashMode,
			preferredGrainPresence: GrainPresence,
			preferredQuantization: Quantization,
			screen: Screen
		) {
			self.shouldReverseCameraControls = false
			self.preferredAspectRatio = preferredAspectRatio
			self.preferredQuantization = preferredQuantization
			self.preferredGrainPresence = preferredGrainPresence
			self.preferredFlashMode = preferredFlashMode
			self.screen = screen
			self.transformation = .init(
				preferredGrainPresence,
				preferredQuantization
			)
			setNeedsUpdateQuantizationRestriction()
		}
	}
	
	public enum Action: Equatable {

		// MARK: Lifecycle
		
		case didAppear
		case didDisappear
		
		case setNeedsUpdatePreferences
		
		// MARK: Camera interactions
		
		case beginCameraInstantiationProcess
		case beginPipelineLoad
		case handlePipelineDidLoad
		
		case requestCameraPermission
		case requestCameraPermissionsResponse(PermissionState)
		
		case requestMicrophonePermission
		case requestMicrophonePermissionsResponse(PermissionState)
		
		case subscribe
		case unsubscribe
		
		// MARK: - IO
		
		case setImageToPersist(Data)
		
		// MARK: - Focus
		
		case setFocus(CGPoint)
		
		// MARK: - Lens Amendments
		
		case toggleCameraPosition
		case updateZoomFactor(start: CGFloat, end: CGFloat)
		case setZoom(ZoomDirection)
		case didBeginLensAmendmentGesture
		case didEndLensAmendmentGesture
		case toggleFlashMode

		// MARK: - Shutter Mechanism Interaction
		
		case didPressShutter(CaptureFormat)
		case fireShutter(CaptureFormat)
		case setCaptureFlashDisabled
		
		// MARK: - Video
		
		case didBeginRecordingGesture
		case didEndRecordingGesture
		case handleRecordedVideo(URL)
		
		// MARK: - Buffer Lifecycle
		
		case handleAvailableZoomFactorsUpdate(ZoomLevelDisplayable?)
		case handleLifecycleClientContent(CaptureLifecycle)
		case handleCapturedImage(AVCapturedImage)
		
		// MARK: Camera processing

		case setPreferredAspectRatio(AspectRatio)
		
		case didRequestAspectRatioOverlayPresentation
		case didRequestCameraPermissionsOverlayPresentation
		case didRequestQuantizationPreferencePresentation
		case didRequestChromaticQuantizationPreferencePresentation
		case didRequestQuantizatonAssociatedVariableIteration
		case didRequestInAppPurchasePresentation
		case setPreferredQuantization(Quantization)
		
		case didRequestGrainPresencePresentation
		case setPreferredGrainPresence(GrainPresence)
		
		case persistPendingCapture
	}
	
	// MARK: Dependencies
	
	@Dependency(\.avCaptureClient) private var avCaptureClient
	@Dependency(\.ciContext) private var ciContext
	@Dependency(\.hapticClient) private var hapticClient
	@Dependency(\.locationClient) private var locationClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.permissionsClient) private var permissionsClient
	@Dependency(\.pipelineClient) private var pipelineClient
	@Dependency(\.pipelineQueue) private var pipelineQueue
	@Dependency(\.preferencesClient) private var preferencesClient
	@Dependency(\.avSchedulers) private var schedulers
	@Dependency(\.shoeboxClient) private var shoeboxClient
	@Dependency(\.shopfrontClient) private var shopfrontClient
	
	// MARK: Initializers
	
	public init() { }
	
	// MARK: ReducerProtocol
	
	public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
		struct AVCaptureZoomFactorsID: Hashable {}
		struct AVCaptureClientContentID: Hashable {}
		struct AVCaptureDevicePositionID: Hashable {}
		struct AVCaptureLifecycleContentID: Hashable {}

		func captureImage() -> EffectTask<Action> {
			avCaptureClient.capture()
			return .none
		}
		
		func setNeedsUpdatePreferences() {
			state.preferredFlashMode = preferencesClient.preferredFlashMode
			state.preferredQuantization = preferencesClient.preferredQuantization
			state.preferredGrainPresence = preferencesClient.preferredGrainPresence
			state.shouldReverseCameraControls = preferencesClient.shouldReverseCameraControls
			state.shutterStyle = preferencesClient.preferredShutterStyle
		}

		func setNeedsUpdateTransformation() -> EffectTask<Action> {
			let transformation = Transformation(
				state.preferredGrainPresence,
				state.preferredQuantization
			)
			state.transformation = transformation
			avCaptureClient.updateTransformation(transformation)
			state.setNeedsUpdateQuantizationRestriction()
			return .none
		}
		
		func startCaptureSessionEffect() -> EffectTask<Action> {
			guard !avCaptureClient.isRunning && !avCaptureClient.isAttemptingToRun else { return .none }
			
			return .concatenate(
				.init(value: .unsubscribe),
				.init(value: .subscribe)
			)
		}
		
		func camerPermissionsOverlayAction() -> EffectTask<Action>? {
			if state.cameraPermissionsNotGranted { return .init(value: .didRequestCameraPermissionsOverlayPresentation) }
			else { return .none }
		}
		
		switch action {
		case .didAppear:
			guard state.screen == .camera else { return .none }
			state.cameraPermission = permissionsClient.checkCameraPermissions
			state.preferredAspectRatio = preferencesClient.preferredAspectRatio
			setNeedsUpdatePreferences()
			
			state.transformation = Transformation(
				state.preferredGrainPresence,
				state.preferredQuantization
			)
			
			return .task {
				_ = try await shopfrontClient.hasActiveSubscription()
				return  .beginCameraInstantiationProcess
			}
			
			
		case .didDisappear:
			var effects: [EffectTask<Action>] = []
			effects.append(.init(value: .unsubscribe))
			return .concatenate(effects)
			
		case .setNeedsUpdatePreferences:
			setNeedsUpdatePreferences()
			return .none
			
		case .beginCameraInstantiationProcess:
			state.setNeedsUpdateQuantizationRestriction()
			
			guard state.hasLoadedPipeline else { return .init(value: .beginPipelineLoad) }
			switch state.cameraPermission {
			case .undetermined, .denied, nil:
				return .none
				
			case .allowed: return startCaptureSessionEffect()
			}
			
		case .beginPipelineLoad:
			return .task {
				try await pipelineClient.loadInitialData()
				return .handlePipelineDidLoad
			}
			
		case .handlePipelineDidLoad:
			state.hasLoadedPipeline = true
			return .init(value: .beginCameraInstantiationProcess)
			
		/// MARK: - Camera
			
		case .requestCameraPermission:
			switch state.cameraPermission {
			case .undetermined, .none:
				return permissionsClient.requestCameraPermissions
					.schedule(with: schedulers)
					.map(Action.requestCameraPermissionsResponse)
					.eraseToEffect()
			case .denied:
				guard let url = URL(string: UIApplication.openSettingsURLString) else { return .none }
				#if !CAPTURE_EXTENSION
//				UIApplication.shared.open(url)
				#endif
			case .allowed: break
			}
			
			return .none
			
		case .requestCameraPermissionsResponse(let cameraPermission):
			state.cameraPermission = cameraPermission
			switch cameraPermission {
			case .allowed: return startCaptureSessionEffect()
			case .denied, .undetermined:
				return .none
			}
			
		case .requestMicrophonePermission:
			return permissionsClient.requestMicrophonePermissions
				.schedule(with: schedulers)
				.map(Action.requestMicrophonePermissionsResponse)
				.eraseToEffect()
			
		case .requestMicrophonePermissionsResponse(let microphonePermission):
			switch microphonePermission {
			case .allowed: avCaptureClient.setupMicrophoneIO()
			case .denied, .undetermined: break
			}
			return .none
			
		case .subscribe:
			avCaptureClient.startCaptureSession(state.transformation)
			
			return .merge(
				avCaptureClient.constituentDevicePublisher
					.map(Action.handleAvailableZoomFactorsUpdate)
					.receive(on: mainQueue)
					.eraseToEffect()
					.cancellable(id: AVCaptureZoomFactorsID(), cancelInFlight: true),
				avCaptureClient.captureLifecyclePublisher
					.map(Action.handleLifecycleClientContent)
					.receive(on: mainQueue)
					.eraseToEffect()
					.cancellable(id: AVCaptureLifecycleContentID(), cancelInFlight: true),
				avCaptureClient.capturedImagePublisher
					.map(Action.handleCapturedImage)
					.receive(on: mainQueue)
					.eraseToEffect()
					.cancellable(id: AVCaptureClientContentID(), cancelInFlight: true)
			)
			.schedule(with: schedulers)
			
		case .unsubscribe:
			if avCaptureClient.isRunning || avCaptureClient.isAttemptingToRun { avCaptureClient.stopCaptureSession() }
			return .merge(
				.cancel(id: AVCaptureLifecycleContentID()),
				.cancel(id: AVCaptureZoomFactorsID()),
				.cancel(id: AVCaptureClientContentID())
			)
			
		case .setImageToPersist(let data):
			return shoeboxClient.persistAsset(
				.photo(data),
				addToPhotoLibrary: preferencesClient.shouldAddCapturesToApplicationPhotoAlbum,
				location: preferencesClient.shouldEmbedLocationDataInCaptures ? locationClient.lastKnownLocation : nil
			).fireAndForget()
			
		case .setFocus(let point):
			avCaptureClient.setFocus(point)
			return .none
			
		case .toggleCameraPosition:
			if let action = camerPermissionsOverlayAction() { return action }
			
			avCaptureClient.toggleCamera()
			return .merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.rigidImpact(1.0).fireAndForget()
			)
			
		case .updateZoomFactor(let low, let high):
			avCaptureClient.updateZoomFactor(low: low, high: high)
			return .none
			
		case .setZoom(let direction):
			guard avCaptureClient.rampToNext(direction) else { return .none }
			return .merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.rigidImpact(1.0).fireAndForget()
			)
			
		case .didBeginLensAmendmentGesture:
			return .merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.rigidImpact(1.0).fireAndForget()
			)
			
		case .didEndLensAmendmentGesture:
			return .merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.rigidImpact(0.5).fireAndForget()
			)
			
		case .toggleFlashMode:
			if let action = camerPermissionsOverlayAction() { return action }
			
			let flashMode = avCaptureClient.toggleFlashMode()
			preferencesClient.setPreferredFlashMode(flashMode)
			setNeedsUpdatePreferences()
			return .merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.rigidImpact(1.0).fireAndForget()
			)
			
		case .didPressShutter(let format):
			if let action = camerPermissionsOverlayAction() { return action }
			
			if ShopfrontClient.shared.hasActiveSubscription { return .init(value: .fireShutter(format)) }
			
			if state.preferredQuantization.isProtectedByIAP {
				return .task(priority: .high) { @MainActor in
					if try await shopfrontClient.hasActiveSubscription() {
						return .fireShutter(format)
					}
					else {
						return .didRequestInAppPurchasePresentation
					}
				}
			}
			else {
				return .init(value: .fireShutter(format))
			}
			
		case .fireShutter(let format):
			switch format {
			case .photo:
				struct BlackoutID: Hashable { }
				state.captureFlashFired = true
				return .concatenate(
					.cancel(id: BlackoutID()),
					.merge(
						captureImage(),
						.merge(
							hapticClient.prepare().fireAndForget(),
							hapticClient.rigidImpact(1.0).fireAndForget()
						),
						.task {
							try? await mainQueue.sleep(for: .seconds(0.10))
							return .setCaptureFlashDisabled
						}
							.schedule(with: schedulers)
							.eraseToEffect()
							.cancellable(id: BlackoutID(), cancelInFlight: true)
					)
				)
				
			case .video:
				let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().uuidString).mp4")
				try? avCaptureClient.startRecordingVideo(url: url)
			}
			
			return .none
			
		case .setCaptureFlashDisabled:
			state.captureFlashFired = false
			return .none
			
		case .didBeginRecordingGesture:
			if permissionsClient.microphonePermissions == .undetermined {
				return .init(value: .requestMicrophonePermission)
			}
			
			return .init(value: .fireShutter(.video))
			
		case .didEndRecordingGesture:
			return .task {
				let url = try await avCaptureClient.stopRecordingVideo()
				return .handleRecordedVideo(url)
			}
			
		case .handleRecordedVideo(let url):
			return shoeboxClient.persistAsset(
				.video(url),
				addToPhotoLibrary: preferencesClient.shouldAddCapturesToApplicationPhotoAlbum,
				location: preferencesClient.shouldEmbedLocationDataInCaptures ? locationClient.lastKnownLocation : nil
			).fireAndForget()
			
		case .handleAvailableZoomFactorsUpdate(let device):
			guard let device = device else { return .none }
			state.zoomLevelDisplayable = device
			return .none
			
		case .handleLifecycleClientContent(let lifecycle):
			let shouldFireHaptic: Bool
			
			switch (state.captureLifecycle, lifecycle) {
			case (.recording(let first), .recording(let second)):
				switch (first.unit, second.unit) {
				case (.seconds, .seconds):
					let lastKnownSecond = Int(first.value.rounded())
					let currentSecond = Int(second.value.rounded())
					shouldFireHaptic = lastKnownSecond != currentSecond
				default: shouldFireHaptic = false
				}
			case (.idle, .recording): shouldFireHaptic = true
			default: shouldFireHaptic = false
			}
			
			state.captureLifecycle = lifecycle
			
			if shouldFireHaptic {
				return .merge(
					hapticClient.prepare().fireAndForget(),
					hapticClient.rigidImpact(1.0).fireAndForget()
				)
			}
			else { return .none }
		
		case .handleCapturedImage(let capturedImage):
			guard
				!state.isCurrentQuantizationRestricted
			else {
				state.pendingRestrictedQuantizationCapture = capturedImage.rawValue
				return .none
			}
			
			return .init(value: .setImageToPersist(capturedImage.rawValue))
			
		case .setPreferredAspectRatio(let ratio):
			preferencesClient.setPreferredAspectRatio(ratio)
			avCaptureClient.setAspectRatio(ratio)
			state.preferredAspectRatio = ratio
			return .none
			
		case .didRequestAspectRatioOverlayPresentation: return .none
		case .didRequestQuantizationPreferencePresentation: return .none
		case .setPreferredQuantization(let quantization):
			preferencesClient.setPreferredQuantization(quantization)
			state.preferredQuantization = quantization
			return setNeedsUpdateTransformation()
			
		case .didRequestCameraPermissionsOverlayPresentation:
			return .none
			
		case .didRequestQuantizatonAssociatedVariableIteration:
			if let action = camerPermissionsOverlayAction() { return action }
			
			switch state.preferredQuantization {
			case .chromatic:
				return .init(value: .didRequestChromaticQuantizationPreferencePresentation)
			case .warhol(let existing):
				state.preferredQuantization = .warhol(existing.next())
				preferencesClient.setPreferredQuantization(state.preferredQuantization)
				return .merge(
					hapticClient.prepare().fireAndForget(),
					hapticClient.rigidImpact(1.0).fireAndForget(),
					setNeedsUpdateTransformation()
				)
			default: break
			}
			return .none
			
		case .persistPendingCapture:
			guard let pending = state.pendingRestrictedQuantizationCapture else { return .none }
			state.pendingRestrictedQuantizationCapture = nil
			return .init(value: .setImageToPersist(pending))

		case .didRequestChromaticQuantizationPreferencePresentation: return .none
		case .didRequestInAppPurchasePresentation: return .none
		case .didRequestGrainPresencePresentation: return .none
		case .setPreferredGrainPresence(let grainPresence):
			preferencesClient.setPreferredGrainPresence(grainPresence)
			state.preferredGrainPresence = grainPresence
			return setNeedsUpdateTransformation()
		}
	}
}
