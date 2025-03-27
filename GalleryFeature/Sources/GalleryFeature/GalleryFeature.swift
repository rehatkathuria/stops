import Foundation
import ComposableArchitecture
import Convenience
import Haptics
import Shared
import Shoebox
import PermissionsClient
import Photos
import Preferences
import UIKit
import Views

public struct GalleryFeature: ReducerProtocol {
	public struct State: Equatable {
		public var shouldDisplayAssetElements: Bool {
			isPresentingDetailedImageView && focusedAsset != nil
		}
		public var shouldDisplayCountdownTimer: Bool {
			isPresentingDetailedImageView
		}
		public var permissionsNotGranted: Bool {
			permissionState != .allowed
		}
		public internal(set) var isPresentingDetailedImageView = false
		public internal(set) var hasFinishedPresenting = true
		public internal(set) var permissionState: PermissionState? = nil
		public internal(set) var focusedDisplayable: GalleryDisplayable?
		public internal(set) var focusedAsset: AssetFavouriteEquatable?
		public internal(set) var shouldPresentShareSheet = false
		public internal(set) var assetImageToShare: UIImage?
		public internal(set) var galleryFilter = GalleryFilter.all
		public internal(set) var isPreparingAssetForShare = false
		public internal(set) var shouldIncludeScreenshots: Bool

		public init() {
			shouldIncludeScreenshots = LivePreferencesClient().shouldIncludeScreenshotsInGallery
		}
	}

	public enum Action: Equatable {
		case begin
		case didAppear

		case didRequestGalleryPermissionsOverlayPresentation
		case requestPermissions
		case handlePermissionsResult(PermissionState)
		
		case setIsPresentingDetailedImageView(Bool)
		case setHasFinishedPresenting(Bool)
		case setFocusedDisplayable(GalleryDisplayable?)

		case didRequestDetailedImageViewDismissal
		case didRequestDeletionOfFocusedDisplayable
		case didRequestToggleFavouriteOfFocusedAsset
		
		case didRequestPresentationHaptic
		case didRequestDismissalHaptic
		
		case setShouldPresentShareSheet(Bool)
		case setAssetShareSheetImage(UIImage?)
		
		case didRequestGalleryFilterOverlayPresentation
		case setPreferredGalleryFiltering(GalleryFilter)
		
		case didRequestGalleryScreenshotsPresenceOverlayPresentation
		case setPreferredGalleryScreenshotsPresenceFiltering(Bool)
	}

	@Dependency(\.hapticClient) private var hapticClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.permissionsClient) private var permissionsClient
	@Dependency(\.preferencesClient) private var preferencesClient
	@Dependency(\.schedulers) private var schedulers
	@Dependency(\.shoeboxClient) private var shoeboxClient
	@Dependency(\.shopfrontClient) private var shopfrontClient
	
	public init() { }
	
	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			core(state: &state, action: action)
		}
	}
	
	func core(state: inout State, action: Action) -> EffectTask<Action> {
		var galleryAmendmentsHapticEffect: EffectTask<Action> {
			.merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.impact().fireAndForget()
			)
			.schedule(with: schedulers)
		}
		
		func setNeedsUpdatePreferencesClientInterests() {
			state.galleryFilter = preferencesClient.preferredGalleryFilter
			state.shouldIncludeScreenshots = preferencesClient.shouldIncludeScreenshotsInGallery
		}
		
		switch action {
		case .didAppear:
			guard state.permissionState == nil else { return .none }
			return .init(value: .begin)
			
		case .begin:
			setNeedsUpdatePreferencesClientInterests()
			return .init(
				value: .handlePermissionsResult(
					permissionsClient.checkPhotoGalleryPermissions
				)
			)
			
		case .handlePermissionsResult(let resultPermissions):
			state.permissionState = resultPermissions
			return .none
			
		case .didRequestGalleryPermissionsOverlayPresentation: return .none
		case .requestPermissions:
			if state.permissionState == .undetermined {
				return permissionsClient.requestPhotoGalleryPermissions
					.map(GalleryFeature.Action.handlePermissionsResult)
					.eraseToEffect()
			}
			else {
				#if !CAPTURE_EXTENSION
				if let url = URL(string: "App-prefs:root=Privacy&path=PHOTOS") {
//					UIApplication.shared.open(url)
				}
				#endif
				return .none
			}
			
		case .setIsPresentingDetailedImageView(let isPresenting):
			state.isPresentingDetailedImageView = isPresenting
			return .none
			
		case .setHasFinishedPresenting(let hasFinished):
			state.hasFinishedPresenting = hasFinished
			return .none
			
		case .didRequestDetailedImageViewDismissal:
			navigationController?.popToRootViewController(animated: true)
			return .merge(
				.init(value: .setIsPresentingDetailedImageView(false)),
				.init(value: .setHasFinishedPresenting(true)),
				.init(value: .didRequestDismissalHaptic),
				.init(value: .setFocusedDisplayable(nil))
			)

		case .setFocusedDisplayable(let displayable):
			if let displayable {
				state.focusedDisplayable = displayable
				state.focusedAsset = .init(rawValue: displayable)
			}
			else { state.focusedDisplayable = nil }
			return .none
			
		case .didRequestDeletionOfFocusedDisplayable:
			guard let displayable = state.focusedDisplayable else { return .none }
			return .merge(
				galleryAmendmentsHapticEffect,
				shoeboxClient.attemptDeletion([displayable]).fireAndForget()
			)
			
		case .didRequestToggleFavouriteOfFocusedAsset:
			guard
				let asset = state.focusedAsset?.rawValue
			else { return .none }
			
			return .merge(
				galleryAmendmentsHapticEffect,
				shoeboxClient.toggleAssetFavourite(asset)
					.map({ Action.setFocusedDisplayable($0 ?? asset) })
					.eraseToEffect()
			)
			
		case .didRequestPresentationHaptic:
			return .merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.impact().fireAndForget()
		 )
			
		case .didRequestDismissalHaptic:
			return .merge(
				hapticClient.prepare().fireAndForget(),
				hapticClient.rigidImpact(0.5).fireAndForget()
		 )
			
		case .setShouldPresentShareSheet(let shouldPresent):
			state.shouldPresentShareSheet = shouldPresent
			
			if shouldPresent, let asset = state.focusedAsset {
				state.isPreparingAssetForShare = true
				return .concatenate(
					galleryAmendmentsHapticEffect,
					.task { 
						let options = PHImageRequestOptions()
						options.deliveryMode = .highQualityFormat
						options.isNetworkAccessAllowed = true
						options.resizeMode = .fast
						
						let result = try await imageManager.requestImage(
							for: asset.rawValue,
							targetSize: .init(
								width: asset.rawValue.pixelWidth,
								height: asset.rawValue.pixelHeight
							),
							contentMode: .aspectFit,
							options: options
						)
						
						return .setAssetShareSheetImage(result)
					}
						.schedule(with: schedulers)
						.eraseToEffect()
				)
			}
			else {
				state.assetImageToShare = nil
				return .none
			}

		case .setAssetShareSheetImage(let image):
			state.assetImageToShare = image
			state.shouldPresentShareSheet = true
			state.isPreparingAssetForShare = false
			return .none
			
		case .didRequestGalleryScreenshotsPresenceOverlayPresentation: return .none
		case .setPreferredGalleryScreenshotsPresenceFiltering(let newValue):
			guard state.shouldIncludeScreenshots != newValue else { return .none }
			state.shouldIncludeScreenshots = newValue
			preferencesClient.setShouldIncludeScreenshotsInGallery(newValue)
			return .none
			
		case .didRequestGalleryFilterOverlayPresentation: return .none
		case .setPreferredGalleryFiltering(let newValue):
			state.galleryFilter = newValue
			preferencesClient.setPreferredGalleryFilter(newValue)
			return .none
		}
	}
}
