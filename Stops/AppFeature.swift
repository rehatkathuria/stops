import AVCaptureClient
import CameraFeature
import ComposableArchitecture
import GalleryFeature
import OrientationClient
import OverlayView
import Settings
import Shared
import Shopfront
import StoreKit
import SwiftUI

public struct AppFeature: ReducerProtocol {
	
	// MARK: - Properties (Dependencies)
	
	@Dependency(\.hapticClient) private var hapticClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.preferencesClient) private var preferencesClient
	@Dependency(\.schedulers) private var schedulers
	@Dependency(\.shopfrontClient) private var shopfrontClient
	
	// MARK: - ReducerProtocol
	
	public struct State: Equatable {
		public var isPresentingSheet: Bool { isSettingsViewVisible || isShopfrontViewVisible }
		public var isHorizontalSwipeEnabled: Bool { !gallery.isPresentingDetailedImageView }
		
		public internal(set) var screen = Screen.camera
		public internal(set) var camera: CameraFeature.State
		public internal(set) var gallery: GalleryFeature.State
		
		public internal(set) var aspectRatioOverlay: OverlayFeature.State?
		public internal(set) var cameraPermissionsOverlay: OverlayFeature.State?
		public internal(set) var galleryPermissionsOverlay: OverlayFeature.State?
		public internal(set) var galleryFilterOverlay: OverlayFeature.State?
		public internal(set) var galleryScreenshotsPresenceOverlay: OverlayFeature.State?
		public internal(set) var grainOverlay: OverlayFeature.State?
		public internal(set) var quantizationOverlay: OverlayFeature.State?
		public internal(set) var quantizationChromaticOverlay: OverlayFeature.State?
		
		public internal(set) var isSettingsViewVisible: Bool
		public internal(set) var settings: SettingsFeature.State?
		
		public internal(set) var isShopfrontViewVisible: Bool
		public internal(set) var shopfront: ShopfrontFeature.State?
		
		public internal(set) var hasAppeared: Bool
		public internal(set) var shouldColourNavigationTitle: Bool
		
		public internal(set) var orientation: UIDeviceOrientation
		public internal(set) var iconRotation: Angle
		
		public init() {
			camera = CameraFeature.State(
				cameraPosition: .front,
				preferredAspectRatio: .fiveByFour,
				preferredFlashMode: .off,
				preferredGrainPresence: .normal,
				preferredQuantization: .chromatic(.tonachrome),
				screen: screen
			)
			gallery = .init()
			hasAppeared = false
			shouldColourNavigationTitle = false
			isSettingsViewVisible = false
			isShopfrontViewVisible = false
			
			orientation = .unknown
			iconRotation = .degrees(0)
			
			aspectRatioOverlay = nil
			grainOverlay = nil
			quantizationOverlay = nil
			settings = nil
			shopfront = ShopfrontFeature.State(page: .colourProfiles)
		}
	}
	
	public enum Action: Equatable {
		case begin
		case setScreen(Screen)
		case staggerNavigationTitleColor
		case completeNavigationTitleColorAnimation
		
		case handleOrientationChange(UIDeviceOrientation)
		case handleTransaction(StoreKit.Transaction)
		
		case aspectRatioOverlay(OverlayFeature.Action)
		case cameraPermissionsOverlay(OverlayFeature.Action)
		case galleryPermissionsOverlay(OverlayFeature.Action)
		case galleryFilterOverlay(OverlayFeature.Action)
		case galleryScreenshotsPresenceOverlay(OverlayFeature.Action)
		case grainOverlay(OverlayFeature.Action)
		case quantizationOverlay(OverlayFeature.Action)
		case quantizationChromaticOverlay(OverlayFeature.Action)
		
		case setIsSettingsViewVisible(Bool)
		case setIsShopfrontVisible(Bool)
		case camera(CameraFeature.Action)
		case gallery(GalleryFeature.Action)
		case settings(SettingsFeature.Action)
		case shopfront(ShopfrontFeature.Action)
	}
	
	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			core(state: &state, action: action)
		}
		.ifLet(\.aspectRatioOverlay, action: /Action.aspectRatioOverlay) {
			OverlayFeature()
		}
		.ifLet(\.quantizationOverlay, action: /Action.quantizationOverlay) {
			OverlayFeature()
		}
		.ifLet(\.quantizationChromaticOverlay, action: /Action.quantizationChromaticOverlay) {
			OverlayFeature()
		}
		.ifLet(\.galleryPermissionsOverlay, action: /Action.galleryPermissionsOverlay) {
			OverlayFeature()
		}
		.ifLet(\.galleryFilterOverlay, action: /Action.galleryFilterOverlay) {
			OverlayFeature()
		}
		.ifLet(\.galleryScreenshotsPresenceOverlay, action: /Action.galleryScreenshotsPresenceOverlay) {
			OverlayFeature()
		}
		.ifLet(\.grainOverlay, action: /Action.grainOverlay) {
			OverlayFeature()
		}
		.ifLet(\.settings, action: /Action.settings) {
			SettingsFeature()
		}
		.ifLet(\.shopfront, action: /Action.shopfront) {
			ShopfrontFeature()
		}
		
		Scope(state: \State.camera, action: /Action.camera) {
			CameraFeature()
		}
		
		Scope(state: \State.gallery, action: /Action.gallery) {
			GalleryFeature()
		}
	}
	
	private func core(state: inout State, action: Action) -> EffectTask<Action> {
		var overlayPresentationEffect: EffectTask<Action> {
			.merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.impact().fireAndForget()
			)
			.schedule(with: schedulers)
		}
		
		var overlayDismissalEffect: EffectTask<Action> {
			.merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.rigidImpact(0.5).fireAndForget()
			)
			.schedule(with: schedulers)
		}
		
		func setNeedsUpdateIconRotationUpdate() {
			let areControlsReversed = state.camera.shouldReverseCameraControls
			
			if state.gallery.isPresentingDetailedImageView || state.screen == .shoebox {
				state.iconRotation = .degrees(0)
			}
			else {
				switch state.orientation {
				case .unknown, .faceUp, .faceDown, .portrait: state.iconRotation = .degrees(0)
				case .landscapeLeft: state.iconRotation = .degrees(areControlsReversed ? -90 : 90)
				case .landscapeRight: state.iconRotation = .degrees(areControlsReversed ? 90 : -90)
				case .portraitUpsideDown: state.iconRotation = .degrees(180)
				@unknown default: state.iconRotation = .degrees(0)
				}
			}
		}
		
		switch action {
		case .begin:
			state.hasAppeared = true
			return .merge(
				hapticClient
					.areHapticsEnabled(preferencesClient.shouldEnableHaptics)
					.fireAndForget(),
				.init(value: .gallery(.begin)),
				.init(value: .shopfront(.load)),
				OrientationClient.shared
					.deviceOrientationPublisher
					.removeDuplicates()
					.map(AppFeature.Action.handleOrientationChange)
					.receive(on: schedulers.main)
					.eraseToEffect(),
				shopfrontClient
					.transactions
					.map(Action.handleTransaction)
					.receive(on: mainQueue)
					.eraseToEffect()
			)
			
		case .handleOrientationChange(let orientation):
			guard state.orientation != orientation else { return .none }
			state.orientation = orientation
			setNeedsUpdateIconRotationUpdate()
			return .none
			
		case .handleTransaction(let transaction):
			if let _ = state.shopfront {
				return .init(value: .shopfront(.handlePurchaseResult(.success(.verified(transaction)))))
			}
			else {
				DispatchQueue.main.async {
					ShopfrontClient.shared.hasActiveSubscription = true
				}
				state.camera.setNeedsUpdateQuantizationRestriction()
				return .init(value: .camera(.persistPendingCapture))
			}
			
		case .setScreen(let screen):
			state.screen = screen
			state.camera.screen = screen
			setNeedsUpdateIconRotationUpdate()
			if screen == .camera {
				return .init(value: .camera(.didAppear))
			}
			else {
				return .merge(
					.init(value: .camera(.didDisappear)),
					.init(value: .gallery(.didAppear))
				)
			}
			
		case .staggerNavigationTitleColor:
			state.shouldColourNavigationTitle = true
			return .init(value: .completeNavigationTitleColorAnimation)
				.delay(for: .seconds(0.75), scheduler: schedulers.main)
				.receive(on: schedulers.main)
				.eraseToEffect()
				.animation()
			
		case .completeNavigationTitleColorAnimation:
			state.shouldColourNavigationTitle = false
			return .none
			
		case .camera(.didRequestInAppPurchasePresentation):
			return .init(value: .setIsShopfrontVisible(true))
			
		case .camera(.didRequestCameraPermissionsOverlayPresentation):
			state.cameraPermissionsOverlay = .init()
			return overlayPresentationEffect
			
		case .camera(.requestCameraPermissionsResponse(let permissions)):
			switch permissions {
			case .allowed: return .init(value: .cameraPermissionsOverlay(.didRequestDismissal))
			case .denied, .undetermined: return .none
			}
			
		case .cameraPermissionsOverlay(.didRequestDismissal):
			state.cameraPermissionsOverlay?.isActive = false
			return overlayDismissalEffect
			
		case .cameraPermissionsOverlay(.setDismissed):
			state.cameraPermissionsOverlay = nil
			return .none
			
		case .camera(.didRequestAspectRatioOverlayPresentation):
			if state.camera.cameraPermissionsNotGranted {
				return .init(value: .camera(.didRequestCameraPermissionsOverlayPresentation))
			}
			
			state.aspectRatioOverlay = .init()
			return overlayPresentationEffect
			
		case .camera(.setPreferredAspectRatio):
			return .init(value: .aspectRatioOverlay(.didRequestDismissal))
			
		case .aspectRatioOverlay(.setDismissed):
			state.aspectRatioOverlay = nil
			return .none
			
		case .aspectRatioOverlay(.didRequestDismissal):
			state.aspectRatioOverlay?.isActive = false
			return overlayDismissalEffect
			
		case .camera(.didRequestGrainPresencePresentation):
			if state.camera.cameraPermissionsNotGranted {
				return .init(value: .camera(.didRequestCameraPermissionsOverlayPresentation))
			}
			
			state.grainOverlay = .init()
			return overlayPresentationEffect
			
		case .camera(.didRequestQuantizationPreferencePresentation):
			if state.camera.cameraPermissionsNotGranted {
				return .init(value: .camera(.didRequestCameraPermissionsOverlayPresentation))
			}
			
			state.quantizationOverlay = .init()
			return overlayPresentationEffect
			
		case .camera(.setPreferredQuantization):
			return .merge(
				.init(value: .quantizationOverlay(.didRequestDismissal)),
				.init(value: .quantizationChromaticOverlay(.didRequestDismissal))
			)
			
		case .quantizationOverlay(.didRequestDismissal):
			state.quantizationOverlay?.isActive = false
			return overlayDismissalEffect
			
		case .quantizationOverlay(.setDismissed):
			state.quantizationOverlay = nil
			return .none
			
		case .camera(.didRequestChromaticQuantizationPreferencePresentation):
			if state.camera.cameraPermissionsNotGranted {
				return .init(value: .camera(.didRequestCameraPermissionsOverlayPresentation))
			}
			
			state.quantizationChromaticOverlay = .init()
			return overlayPresentationEffect
			
		case .quantizationChromaticOverlay(.didRequestDismissal):
			state.quantizationChromaticOverlay?.isActive = false
			return overlayDismissalEffect
			
		case .quantizationChromaticOverlay(.setDismissed):
			state.quantizationChromaticOverlay = nil
			return .none
			
		case .gallery(.didRequestGalleryPermissionsOverlayPresentation):
			state.galleryPermissionsOverlay = .init()
			return overlayPresentationEffect
			
		case .gallery(.handlePermissionsResult(let permissions)):
			switch permissions {
			case .allowed:
				
				return .concatenate(
					.init(
						value: .galleryPermissionsOverlay(.didRequestDismissal)
					)
				)
			case .denied, .undetermined: return .none
			}
			
		case .gallery(.didRequestGalleryScreenshotsPresenceOverlayPresentation):
			if state.gallery.permissionsNotGranted {
				return .init(value: .gallery(.didRequestGalleryPermissionsOverlayPresentation))
			}
			
			state.galleryScreenshotsPresenceOverlay = .init()
			return overlayPresentationEffect
			
		case .gallery(.setPreferredGalleryScreenshotsPresenceFiltering): return .init(value: .galleryScreenshotsPresenceOverlay(.didRequestDismissal))
		case .galleryScreenshotsPresenceOverlay(.didRequestDismissal):
			state.galleryScreenshotsPresenceOverlay?.isActive = false
			return overlayDismissalEffect
			
		case .gallery(.didRequestGalleryFilterOverlayPresentation):
			if state.gallery.permissionsNotGranted {
				return .init(value: .gallery(.didRequestGalleryPermissionsOverlayPresentation))
			}
			
			state.galleryFilterOverlay = .init()
			return overlayPresentationEffect
			
		case .gallery(.setPreferredGalleryFiltering): return .init(value: .galleryFilterOverlay(.didRequestDismissal))
		case .galleryFilterOverlay(.didRequestDismissal):
			state.galleryFilterOverlay?.isActive = false
			return overlayDismissalEffect
			
		case .camera(.setPreferredGrainPresence): return .init(value: .grainOverlay(.didRequestDismissal))
		case .grainOverlay(.didRequestDismissal):
			state.grainOverlay?.isActive = false
			return overlayDismissalEffect
			
		case .grainOverlay(.setDismissed):
			state.grainOverlay = nil
			return .none
			
		case .setIsSettingsViewVisible(let isVisible):
			state.isSettingsViewVisible = isVisible
			state.settings = isVisible ? .init() : nil
			if isVisible {
				return .merge(
					overlayPresentationEffect,
					.init(value: .camera(.unsubscribe))
				)
			}
			else if state.screen == .camera, let permission = state.camera.cameraPermission, permission == .allowed {
				return .init(value: .camera(.subscribe))
			}
			
			return .none
			
		case .setIsShopfrontVisible(let isVisible):
			state.isShopfrontViewVisible = isVisible
			state.shopfront = isVisible
				? .init(
					attemptedToCapture: nil,
					attemptedCaptureQuantization: .chromatic(.folia),
					page: .colourProfiles
				)
				: nil
			if isVisible {
				return .merge(
					overlayPresentationEffect,
					.init(value: .camera(.unsubscribe))
				)
			}
			else if state.screen == .camera, let permission = state.camera.cameraPermission, permission == .allowed {
				return .init(value: .camera(.subscribe))
			}
			return .none
			
		case .settings(.setShouldEnableHaptics(let should)):
			return hapticClient.areHapticsEnabled(should).fireAndForget()
			
		case .settings(.setShutterStyle),
				.settings(.setShouldDoubleTapToFlipCamera),
				.settings(.setShouldReverseCameraControls):
			return .init(value: .camera(.setNeedsUpdatePreferences))
			
		case .shopfront(.handlePurchaseResult(let result)):
			state.camera.setNeedsUpdateQuantizationRestriction()
			guard case .success = result else { return .none }
			return .merge(
				.init(value: .setIsShopfrontVisible(false)),
				.init(value: .camera(.persistPendingCapture))
			)
			
		case .camera: return .none
		case .gallery: return .none
		case .settings: return .none
		case .shopfront: return .none
			
		case .aspectRatioOverlay: return .none
		case .galleryFilterOverlay: return .none
		case .quantizationOverlay: return .none
		case .quantizationChromaticOverlay: return .none
		case .cameraPermissionsOverlay: return .none
		case .galleryPermissionsOverlay: return .none
		case .galleryScreenshotsPresenceOverlay: return .none
		case .grainOverlay: return .none
		}
	}
	
}
