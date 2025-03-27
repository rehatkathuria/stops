import CameraFeature
import ComposableArchitecture
import Foundation
import GalleryFeature
import SwiftUI
import Views

public struct AppOverlays: View {
	
	// MARK: - Properties
	
	private let store: StoreOf<AppFeature>
	
	@Environment(\.locale) var locale

	// MARK: - Lifecycle
	
	public init(_ store: StoreOf<AppFeature>) { self.store = store }
	
	// MARK: - Helpers
	
	@ViewBuilder
	private func cameraOverlays(_ store: StoreOf<AppFeature>) -> some View {
		WithViewStore(
			store.scope(state: \.camera, action: AppFeature.Action.camera),
			observe: \.preferredAspectRatio
		) { viewStore in
			IfLetStore(
				store.scope(
					state: \.aspectRatioOverlay,
					action: AppFeature.Action.aspectRatioOverlay
				)
			) { appStore in
				aspectRatioOverlay(
					appStore,
					viewStore: viewStore,
					locale: locale
				)
			}
		}
		
		WithViewStore(
			store.scope(state: \.camera, action: AppFeature.Action.camera),
			observe: \.preferredQuantization
		) { viewStore in
			IfLetStore(
				store.scope(
					state: \.quantizationOverlay,
					action: AppFeature.Action.quantizationOverlay
				)
			) { quantizationStore in
				quantizationPreferenceOverlay(
					quantizationStore,
					viewStore: viewStore,
					locale: locale
				)
			}
		}

		WithViewStore(
			store.scope(state: \.camera, action: AppFeature.Action.camera),
			observe: \.preferredQuantization.minor
		) { viewStore in
			IfLetStore(
				store.scope(
					state: \.quantizationChromaticOverlay,
					action: AppFeature.Action.quantizationChromaticOverlay
				)
			) { quantizationStore in
				quantizationChromaticPreferenceOverlay(
					quantizationStore,
					viewStore: viewStore,
					locale: locale
				)
			}
		}

		WithViewStore(
			store.scope(state: \.camera, action: AppFeature.Action.camera),
			observe: \.preferredGrainPresence
		) { viewStore in
			IfLetStore(
				store.scope(
					state: \.grainOverlay,
					action: AppFeature.Action.grainOverlay
				)
			) { grainStore in
				grainPresenceOverlay(
					grainStore,
					viewStore: viewStore
				)
			}
		}
	}
	
	@ViewBuilder
	private func galleryOverlays(_ store: StoreOf<AppFeature>) -> some View {
		WithViewStore(
			store.scope(
				state: \.gallery,
				action: AppFeature.Action.gallery
			)
		) { scopedViewStore in
			IfLetStore(
				store.scope(
					state: \.galleryFilterOverlay,
					action: AppFeature.Action.galleryFilterOverlay
				)
			) { scopedStore in
				galleryFilterOverlay(
					scopedStore,
					viewStore: scopedViewStore,
					locale: locale
				)
			}
			
			IfLetStore(
				store.scope(
					state: \.galleryScreenshotsPresenceOverlay,
					action: AppFeature.Action.galleryScreenshotsPresenceOverlay
				)
			) { scopedStore in
				galleryScreenshotsPresenceOverlay(
					scopedStore,
					viewStore: scopedViewStore,
					locale: locale
				)
			}

			IfLetStore(
				store.scope(
					state: \.cameraPermissionsOverlay,
					action: AppFeature.Action.cameraPermissionsOverlay
				)
			) { scopedStore in
				cameraPermissionsOverlay(
					scopedStore,
					store.scope(
						state: \.camera,
						action: AppFeature.Action.camera
					)
				)
			}
			
			IfLetStore(
				store.scope(
					state: \.galleryPermissionsOverlay,
					action: AppFeature.Action.galleryPermissionsOverlay
				)
			) { scopedStore in
				galleryPermissionsOverlay(
					scopedStore,
					store.scope(
						state: \.gallery,
						action: AppFeature.Action.gallery
					)
				)
			}
			
		}
	}
	
	public var body: some View {
		cameraOverlays(store)
		
		galleryOverlays(store)
	}
	
}
