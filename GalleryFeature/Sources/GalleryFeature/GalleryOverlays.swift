import Aesthetics
import ComposableArchitecture
import Foundation
import OverlayView
import Shared
import Shopfront
import SwiftUI

@ViewBuilder
public func galleryFilterOverlay(
	_ store: Store<OverlayFeature.State, OverlayFeature.Action>,
	viewStore: ViewStore<GalleryFeature.State, GalleryFeature.Action>,
	locale: Locale
) -> some View {
	OverlayView(
		store: store,
		styling: .rows([
			.init(
				action: { viewStore.send(.setPreferredGalleryFiltering(.all)) },
				buttonColor: .bubblegum,
				buttonOverlayColor: .black,
				image: .image(Asset.Phosphor.globe.swiftUIImage),
				title: L10n.entireLibrary,
				subtitle: L10n.theDefaultAlbumWhichIncludesEveryPhotoInYourLibrary,
				selected: viewStore.galleryFilter == .all
			),
			.init(
				action: { viewStore.send(.setPreferredGalleryFiltering(.selfies)) },
				buttonColor: .orange,
				buttonOverlayColor: .black,
				image: .image(Asset.Phosphor.baby.swiftUIImage),
				title: L10n.selfies,
				subtitle: L10n.anAlbumThatIncludesEveryPhotoTakenWithTheFrontFacingCamera,
				selected: viewStore.galleryFilter == .selfies
			),
			.init(
				action: { viewStore.send(.setPreferredGalleryFiltering(.favourites)) },
				buttonColor: .watermelon,
				buttonOverlayColor: .white,
				image: .image(Asset.Phosphor.heartStraight.swiftUIImage),
				title: L10n.favourites,
				subtitle: L10n.anAlbumFilledWithYourFavouritePhotographsAsMarkedByYou,
				selected: viewStore.galleryFilter == .favourites
			)
		])
	)
}

@ViewBuilder
public func galleryScreenshotsPresenceOverlay(
	_ store: Store<OverlayFeature.State, OverlayFeature.Action>,
	viewStore: ViewStore<GalleryFeature.State, GalleryFeature.Action>,
	locale: Locale
) -> some View {
	OverlayView(
		store: store,
		styling: .rows([
			.init(
				action: { viewStore.send(.setPreferredGalleryScreenshotsPresenceFiltering(false)) },
				buttonColor: .orange,
				buttonOverlayColor: .black,
				image: .image(Asset.Phosphor.eyeSlash.swiftUIImage),
				title: L10n.hideScreenshots,
				subtitle: L10n.whenViewingTheEntireAlbumOrYourFavouritesScreenshotsWillBeHidden,
				selected: !viewStore.shouldIncludeScreenshots
			),
			.init(
				action: { viewStore.send(.setPreferredGalleryScreenshotsPresenceFiltering(true)) },
				buttonColor: Color(hex: 0x7C52F6),
				buttonOverlayColor: .black,
				image: .image(Asset.Phosphor.selectionBackground.swiftUIImage),
				title: L10n.showScreenshots,
				subtitle: L10n.screenshotsWillBeVisibleInAlbumsThatIncludeThem,
				selected: viewStore.shouldIncludeScreenshots
			)
		])
	)
}

@ViewBuilder
public func galleryPermissionsOverlay(
	_ store: Store<OverlayFeature.State, OverlayFeature.Action>,
	_ galleryStore: StoreOf<GalleryFeature>
) -> some View {
	OverlayView(
		store: store,
		styling: .view(AnyView(GalleryPermissionsView(galleryStore)))
	)
}
