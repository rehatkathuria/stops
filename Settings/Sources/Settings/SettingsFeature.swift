import Aesthetics
import AVCaptureClient
import AVFoundation
import ComposableArchitecture
import CoreLocation
import Haptics
import LocationClient
import PermissionsClient
import Preferences
import Shared
import Shopfront
import StoreKit
import SwiftUI

public struct SettingsFeature: ReducerProtocol {
	public struct State: Equatable {
		public internal(set) var alternativeAppIconName: String? = {
//		#if !CAPTURE_EXTENSION
//			UIApplication.shared.alternateIconName
//		#else
			nil
//		#endif
		}()

		public internal(set) var defaultCameraPosition: AVCaptureDevice.Position
		public internal(set) var doubleTapToFlipCamera: Bool

		public internal(set) var shouldAddCapturesToApplicationPhotoAlbum: Bool
		public internal(set) var shouldEmbedLocationDataInCaptures: Bool
		public internal(set) var shouldEnableHaptics: Bool
		public internal(set) var shouldEnableSoundEffects: Bool
		public internal(set) var shouldPresentProUpgradeOverlay: Bool
		public internal(set) var shouldReverseCameraControls: Bool
		public internal(set) var shutterStyle: ShutterStyle
		
		public internal(set) var pendingAppIcon: AppIcon?
		
		public internal(set) var shopfront = ShopfrontFeature.State(page: .customAppIcons)
		
		public init() {
			defaultCameraPosition = .back
			doubleTapToFlipCamera = false
			shouldAddCapturesToApplicationPhotoAlbum = false
			shouldEmbedLocationDataInCaptures = false
			shouldEnableHaptics = false
			shouldEnableSoundEffects = false
			shouldPresentProUpgradeOverlay = false
			shouldReverseCameraControls = false
			shutterStyle = .dedicatedButton
		}
	}
	
	public enum Action: Equatable {
		case begin

		case didRequestProUpgradeOverlayPresentation
		case setIsPresentingProUpgradeOverlay(Bool)
		
		case didRequestSetAppIcon(AppIcon)
		case setAppIcon(AppIcon?)
		
		case didRequestAppStoreSync
		case didRequestToRateApp
		case didRequestStopsProManagement
		
		case handleLocationResult(CLAuthorizationStatus)
		
		case setShouldAddCapturesToApplicationPhotoAlbum(Bool)
		case setShouldEmbedLocationDataInCaptures(Bool)
		case setShouldDoubleTapToFlipCamera(Bool)
		case setShouldEnableHaptics(Bool)
		case setShouldEnableSoundEffects(Bool)
		case setShouldReverseCameraControls(Bool)
		case setShutterStyle(ShutterStyle)
		case setToggleDefaultCameraPosition
		
		case setWantsInstagramNavigation
		case setWantsTelegramNavigation
		case setWantsTermsOfUseNavigation
		
		case shopfront(ShopfrontFeature.Action)
	}

	@Dependency(\.avCaptureClient) var avCaptureClient
	@Dependency(\.locationClient) var locationClient
	@Dependency(\.permissionsClient) var permissionsClient
	@Dependency(\.preferencesClient) var preferencesClient
	@Dependency(\.mainQueue) private var main
	@Dependency(\.shopfrontClient) var shopfrontClient
	@Dependency(\.hapticClient) var hapticClient
	
	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			core(state: &state, action: action)
		}
		
		Scope(state: \.shopfront, action: /SettingsFeature.Action.shopfront) {
			ShopfrontFeature()
		}
	}
	
	func core(state: inout State, action: Action) -> EffectTask<Action> {
		func updateLocationClientTracking() -> EffectTask<Action> {
			if state.shouldEmbedLocationDataInCaptures {
				if locationClient.permission == .notDetermined {
					return .task {
						let permission = await locationClient.requestPermission(with: .whenInUsage)
						if permission == .authorizedWhenInUse { locationClient.setNeedsUpdateLocation() }
						return .handleLocationResult(permission)
					}
				}
				else if locationClient.permission == .denied {
					state.shouldEmbedLocationDataInCaptures = false
				}
				else {
					locationClient.setNeedsUpdateLocation()
				}
			}
			
			return .none
		}
		
		switch action {
		case .begin:
			state.defaultCameraPosition = preferencesClient.preferredLaunchDevicePosition
			state.shouldAddCapturesToApplicationPhotoAlbum = preferencesClient.shouldAddCapturesToApplicationPhotoAlbum
			state.shouldEmbedLocationDataInCaptures = preferencesClient.shouldEmbedLocationDataInCaptures && locationClient.permission == .authorizedWhenInUse
			state.doubleTapToFlipCamera = preferencesClient.shouldDoubleTapToFlipCamera
			state.shouldEnableHaptics = preferencesClient.shouldEnableHaptics
			state.shouldEnableSoundEffects = preferencesClient.shouldEnableSoundEffects
			state.shouldReverseCameraControls = preferencesClient.shouldReverseCameraControls
			state.shutterStyle = preferencesClient.preferredShutterStyle
			
			return updateLocationClientTracking()
			
		case .didRequestProUpgradeOverlayPresentation:
			return .init(value: .setIsPresentingProUpgradeOverlay(true))
			
		case .setIsPresentingProUpgradeOverlay(let should):
			state.shouldPresentProUpgradeOverlay = should
			if !should {
				state.pendingAppIcon = nil
			}
			return .none
			
		case .didRequestSetAppIcon(let icon):
			state.pendingAppIcon = icon
			return .task { @MainActor in
//				#if !CAPTURE_EXTENSION
//				guard
//					UIApplication.shared.alternateIconName != icon.iconName
//				else { throw SettingsError.iconAlreadySet }
//
//				guard
//					icon != .primary
//				else {
					return .setAppIcon(nil)
//				}
//				
//				guard
//					try await shopfrontClient.hasActiveSubscription()
//				else { return .didRequestProUpgradeOverlayPresentation }
//				
//				return .setAppIcon(icon)
//				#endif
			}
			
		case .setAppIcon(let icon):
			state.alternativeAppIconName = icon?.iconName
			return .fireAndForget { @MainActor in
				#if !CAPTURE_EXTENSION
//				do { try await UIApplication.shared.setAlternateIconName(icon?.iconName) }
//				catch { }
				#endif
			}
			
		case .didRequestAppStoreSync:
			return .fireAndForget {
				try await AppStore.sync()
			}
			
		case .didRequestStopsProManagement:
//			#if !CAPTURE_EXTENSION
//			if ShopfrontClient.shared.hasActiveSubscription {
//				if let windowScene = UIApplication.shared.connectedScenes
//					.map(\.session.scene)
//					.compactMap({ $0 as? UIWindowScene })
//					.first {
//						return .fireAndForget { try await AppStore.showManageSubscriptions(in: windowScene) }
//					}
//					else { return .none }
//			}
//			else {
//				return .init(value: .setIsPresentingProUpgradeOverlay(true))
//					.receive(on: main)
//					.eraseToEffect()
//			}
//			#else
			return .none
//			#endif
			
		case .didRequestToRateApp:
//			#if !CAPTURE_EXTENSION
//			if let windowScene = UIApplication.shared.connectedScenes
//				.map(\.session.scene)
//				.compactMap({ $0 as? UIWindowScene })
//				.first { SKStoreReviewController.requestReview(in: windowScene) }
//			#endif
			return .none
			
		case .handleLocationResult(let result):
			if result == .denied { state.shouldEmbedLocationDataInCaptures = false }
			return .none
			
		case .setShouldAddCapturesToApplicationPhotoAlbum(let should):
			preferencesClient.setShouldAddCapturesToApplicationPhotoAlbum(should)
			state.shouldAddCapturesToApplicationPhotoAlbum = should
			return .none
			
		case .setShouldEmbedLocationDataInCaptures(let should):
			if should, locationClient.permission == .denied {
				permissionsClient.openSystemSettings()
				return .none
			}
			
			preferencesClient.setShouldEmbedLocationDataInCaptures(should)
			state.shouldEmbedLocationDataInCaptures = should
			return updateLocationClientTracking()
			
		case .setShouldDoubleTapToFlipCamera(let should):
			preferencesClient.setShouldDoubleTapToFlipCamera(should)
			state.doubleTapToFlipCamera = preferencesClient.shouldDoubleTapToFlipCamera
			return .none
			
		case .setShouldEnableHaptics(let should):
			preferencesClient.setShouldEnableHaptics(should)
			state.shouldEnableHaptics = preferencesClient.shouldEnableHaptics
			return .none
			
		case .setShouldEnableSoundEffects(let should):
			preferencesClient.setShouldEnableSoundEffects(should)
			state.shouldEnableSoundEffects = preferencesClient.shouldEnableSoundEffects
			return .none
			
		case .setShouldReverseCameraControls(let shouldReverse):
			preferencesClient.setshouldReverseCameraControls(shouldReverse)
			state.shouldReverseCameraControls = shouldReverse
			return .none
			
		case .setShutterStyle(let style):
			preferencesClient.setPreferredShutterStyle(style)
			state.shutterStyle = style
			return .merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.impact().fireAndForget()
			)
			
		case .setToggleDefaultCameraPosition:
			let toggled: AVCaptureDevice.Position = state.defaultCameraPosition == .front ? .back : .front
			preferencesClient.setPreferredLaunchDevicePosition(toggled)
			state.defaultCameraPosition = toggled
			return .merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.impact().fireAndForget()
			)
			
		case .setWantsInstagramNavigation:
			guard
				let appURL = URL(string: "instagram://user?username=effcorp"),
				let safariURL = URL(string: "https://instagram.com/effcorp")
			else { return .none }
			
//			#if !CAPTURE_EXTENSION
//			if UIApplication.shared.canOpenURL(appURL) { UIApplication.shared.open(appURL) }
//			else { UIApplication.shared.open(safariURL) }
//			#endif
			return .none
			
		case .setWantsTelegramNavigation:
			guard
				let appURL = URL(string: "tg://+NkM5TZhu7gRmNGY0"),
				let safariURL = URL(string: "https://t.me/+NkM5TZhu7gRmNGY0")
			else { return .none }
			
//			#if !CAPTURE_EXTENSION
//			if UIApplication.shared.canOpenURL(appURL) { UIApplication.shared.open(appURL) }
//			else { UIApplication.shared.open(safariURL) }
//			#endif
			return .none

		case .setWantsTermsOfUseNavigation:
			guard
				let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
			else { return .none }
			
//			#if !CAPTURE_EXTENSION
//			if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
//			#endif
			
			return .none

		case .shopfront(.handlePurchaseResult(let result)):
			var effects: [EffectTask<Action>] = [
				.init(value: .setIsPresentingProUpgradeOverlay(false))
			]
			
			switch result {
			case .success:
				if let icon = state.pendingAppIcon {
					state.pendingAppIcon = nil
					effects.append(
						.init(value: .setAppIcon(icon))
							.delay(for: .seconds(0.5), scheduler: DispatchQueue.main.eraseToAnyScheduler())
							.eraseToEffect()
					)
					return .concatenate(effects)
				}
				else { return .concatenate(effects) }
				
			default: return .none
			}
			
		case .shopfront: return .none
			
		}
	}

	public init() { }
}
