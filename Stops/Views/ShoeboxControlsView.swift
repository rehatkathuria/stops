import Aesthetics
import CameraFeature
import ComposableArchitecture
import ExtensionKit
import Photos
import Shared
import SwiftUI
import Views

public struct ShoeboxControlsView: View {
	private var appStore: StoreOf<AppFeature>
	private var store: StoreOf<CameraFeature>
	@State var focusedAsset: PHAsset?
	@Environment(\.lacksPhysicalHomeButton) var lacksPhysicalHomeButton
	
	public init(_ appStore: StoreOf<AppFeature>, _ store: StoreOf<CameraFeature>) {
		self.appStore = appStore
		self.store = store
	}
	
	// MARK: - Views
	
	@ViewBuilder
	private func controls() -> some View {
		WithViewStore(
			appStore.scope(
				state: \.gallery,
				action: AppFeature.Action.gallery
			)
		) { viewStore in
			let offset = CGFloat(100)
			
			HStack {
				ZStack(alignment: .leading) {
					SquareButton(
						image: .image(Asset.Phosphor.gridFour.swiftUIImage),
						backgroundColor: .blue,
						foregroundColor: .white,
						imageScale: .large
					) {
						viewStore.send(.didRequestDetailedImageViewDismissal)
					}
					.offset(y: viewStore.isPresentingDetailedImageView ? 0 : offset)
					.animation(.springable, value: viewStore.isPresentingDetailedImageView)

					HStack {
						SquareButton(
							image: .image(Asset.Phosphor.dotsNine.swiftUIImage),
							backgroundColor: .bubblegum,
							foregroundColor: .black,
							imageScale: .large
						) {
							viewStore.send(.didRequestGalleryFilterOverlayPresentation)
						}
						.offset(y: viewStore.isPresentingDetailedImageView ? offset : 0)
						.animation(.springable, value: viewStore.isPresentingDetailedImageView)
						
						if viewStore.galleryFilter != .selfies {
							SquareButton(
								image: .image(Asset.Phosphor.linkBreak.swiftUIImage),
								backgroundColor: .orange,
								foregroundColor: .black,
								imageScale: .large
							) {
								viewStore.send(.didRequestGalleryScreenshotsPresenceOverlayPresentation)
							}
							.offset(y: viewStore.isPresentingDetailedImageView ? offset : 0)
							.animation(.springable.delay(0.10), value: viewStore.isPresentingDetailedImageView)
						}
					}
						.allowsHitTesting(viewStore.hasFinishedPresenting)
				}

				Spacer()
				
				SquareButton(
					image: viewStore.focusedAsset?.rawValue.isFavorite ?? false
						? .image(Asset.PhosphorFill.heartStraightFill.swiftUIImage)
						: .image(Asset.PhosphorBold.heartStraightBold.swiftUIImage),
					backgroundColor: (viewStore.focusedAsset?.rawValue.isFavorite ?? false) ? .init(hex: 0xF3B45E) : .seaSalt,
					foregroundColor: (viewStore.focusedAsset?.rawValue.isFavorite ?? false) ? .white : .gray,
					imageScale: .medium
				) {
					viewStore.send(.didRequestToggleFavouriteOfFocusedAsset)
				}
				.offset(y: viewStore.shouldDisplayAssetElements ? 0 : offset)
				.animation(.springable.delay(0.1), value: viewStore.shouldDisplayAssetElements)

				SquareButton(
					image: .image(Asset.PhosphorBold.exportBold.swiftUIImage),
					backgroundColor: .purple,
					foregroundColor: .white,
					imageScale: .medium
				) {
					guard !viewStore.isPreparingAssetForShare else { return }
					viewStore.send(.setShouldPresentShareSheet(true))
				}
				.overlay(isShown: viewStore.isPreparingAssetForShare, {
					ProgressView()
						.background(.purple)
						.progressViewStyle(.circular)
				})
				.offset(y: viewStore.shouldDisplayAssetElements ? 0 : offset)
				.animation(.springable.delay(0.15), value: viewStore.shouldDisplayAssetElements)

				SquareButton(
					image: .image(Asset.PhosphorBold.trashSimpleBold.swiftUIImage),
					backgroundColor: .watermelon,
					foregroundColor: .white,
					imageScale: .medium
				) {
					viewStore.send(.didRequestDeletionOfFocusedDisplayable)
				}
				.offset(y: viewStore.isPresentingDetailedImageView ? 0 : offset)
				.animation(.springable.delay(0.2), value: viewStore.isPresentingDetailedImageView)
				
			}
			.padding()
		}
	}

	public var body: some View {
		WithViewStore(appStore) { viewStore in
			controls()
				.offset(y: viewStore.screen == .shoebox ? 0.0 : AppView.controlsOffset)
				.animation(.springable, value: viewStore.screen)
		}
	}
}

struct ShoeboxControlsView_Preview: PreviewProvider {
	static var previews: some View {
		let cameraFeatureState: CameraFeature.State = {
			var cameraState = CameraFeature.State(
				cameraPosition: .front,
				preferredAspectRatio: .oneByOne,
				preferredFlashMode: .on,
				preferredGrainPresence: .none,
				preferredQuantization: .chromatic(.tonachrome),
				screen: .camera
			)
			cameraState.cameraPermission = .allowed
			return cameraState
		}()
		
		CameraControlsView(
			.init(initialState: .init(), reducer: AppFeature()),
			.init(
				initialState: cameraFeatureState,
				reducer: CameraFeature()
			)
		)
			.previewLayout(.sizeThatFits)
			.preferredColorScheme(.dark)
			.registerCustomFonts()
	}
}

