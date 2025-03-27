import Aesthetics
import ComposableArchitecture
import Foundation
import OverlayView
import Shared
import SwiftUI

@ViewBuilder
public func aspectRatioOverlay(
	_ store: Store<OverlayFeature.State, OverlayFeature.Action>,
	viewStore: ViewStore<AspectRatio, CameraFeature.Action>,
	locale: Locale
) -> some View {
	OverlayView(
		store: store,
		styling: .rows([
			.init(
				action: { viewStore.send(.setPreferredAspectRatio(.threeByTwo)) },
				buttonColor: .init(hex: 0xFEBD02),
				buttonOverlayColor: .black,
				image: .image(Asset.PhosphorFill.numberSquareThreeFill.swiftUIImage),
				title: L10n._32,
				subtitle: L10n.popularisedBy35mmFilmThisFormatHasANostalgicFeelToIt,
				selected: viewStore.state == .threeByTwo
			),
			.init(
				action: { viewStore.send(.setPreferredAspectRatio(.fourByThree)) },
				buttonColor: .init(hex: 0x147969),
				buttonOverlayColor: .white,
				image: .image(Asset.PhosphorFill.numberSquareFourFill.swiftUIImage),
				title: L10n._43,
				subtitle: L10n.aPopularFormatThatMatchesTheSensorOnThisPhone,
				selected: viewStore.state == .fourByThree
			),
			.init(
				action: { viewStore.send(.setPreferredAspectRatio(.fiveByFour)) },
				buttonColor: .bubblegum,
				buttonOverlayColor: .black,
				image: .image(Asset.PhosphorFill.numberSquareFiveFill.swiftUIImage),
				title: L10n._54,
				subtitle: L10n.mostCommonInLargeFormatPhotographyThisIsOneAlsoUsedOnInstagram,
				selected: viewStore.state == .fiveByFour
			),
			.init(
				action: { viewStore.send(.setPreferredAspectRatio(.oneByOne)) },
				buttonColor: .seaBlue,
				buttonOverlayColor: .white,
				image: .image(Asset.PhosphorFill.numberSquareOneFill.swiftUIImage),
				title: L10n._11,
				subtitle: L10n.famouslyUsedByVivianMaierThisFormatHasAVeryDistinctiveLookToIt,
				selected: viewStore.state == .oneByOne
			),
		])
	)
}

@ViewBuilder
public func quantizationPreferenceOverlay(
	_ store: Store<OverlayFeature.State, OverlayFeature.Action>,
	viewStore: ViewStore<Quantization, CameraFeature.Action>,
	locale: Locale
) -> some View {
	OverlayView(
		store: store,
		styling: .rows([
			.init(
				action: { viewStore.send(.setPreferredQuantization(.chromatic(.tonachrome))) },
				buttonColor: .orange,
				buttonOverlayColor: .black,
				image: .image(Asset.Phosphor.palette.swiftUIImage),
				title: L10n.chromatic,
				subtitle: L10n.colourQuantizationsWithStunningTonalityAndBeautifulContrast,
				selected: viewStore.state == .chromatic(.folia) || viewStore.state == .chromatic(.supergold) || viewStore.state == .chromatic(.tonachrome)
			),
			.init(
				action: { viewStore.send(.setPreferredQuantization(.monochrome)) },
				buttonColor: .black,
				buttonOverlayColor: .watermelon,
				image: .image(Asset.Phosphor.intersect.swiftUIImage),
				title: L10n.monochrome,
				subtitle: L10n.aMonoRepresentationWithFineTonalityThatSpansSoftShadowsAndVividHighlights,
				selected: viewStore.state == .monochrome
			),
			.init(
				action: { viewStore.send(.setPreferredQuantization(.warhol(.bubblegum))) },
				buttonColor: .green,
				buttonOverlayColor: .black,
				image: .image(Asset.Phosphor.flower.swiftUIImage),
				title: L10n.quirky,
				subtitle: L10n.quantizationsThatAreReminiscentOfU201CHappyAccidentsu201D,
				selected: viewStore.state == .warhol(.bubblegum) || viewStore.state == .warhol(.darkroom) || viewStore.state == .warhol(.glowInTheDark) || viewStore.state == .warhol(.habenero),
				iconXOffset: 0,
				iconYOffset: 0
			),
		])
	)
}

@ViewBuilder
public func quantizationChromaticPreferenceOverlay(
	_ store: Store<OverlayFeature.State, OverlayFeature.Action>,
	viewStore: ViewStore<Quantization.Minor?, CameraFeature.Action>,
	locale: Locale
) -> some View {
	OverlayView(
		store: store,
		styling: .rows([
			.init(
				action: { viewStore.send(.setPreferredQuantization(.chromatic(.folia))) },
				buttonColor: .init(hex: 0xCBD6CB),
				buttonOverlayColor: .init(hex: 0x193D35),
				image: .image(Asset.Phosphor.grains.swiftUIImage),
				title: L10n.folia,
				subtitle: L10n.vividGreenHuesParticularlySuitedToPhotographyWithFoliage,
				selected: viewStore.state == .chromatic(.folia)
			),
			.init(
				action: { viewStore.send(.setPreferredQuantization(.chromatic(.supergold))) },
				buttonColor: .orange,
				buttonOverlayColor: .black,
				image: .image(Asset.Phosphor.sunHorizon.swiftUIImage),
				title: L10n.supergold,
				subtitle: L10n.warmProfileWithASubtleContrastBoostBestPairedWithAFlash,
				selected: viewStore.state == .chromatic(.supergold)
			),
			.init(
				action: { viewStore.send(.setPreferredQuantization(.chromatic(.tonachrome))) },
				buttonColor: .init(hex: 0x6A40B5),
				buttonOverlayColor: .white,
				image: .image(Asset.Phosphor.hexagon.swiftUIImage),
				title: L10n.tonachrome,
				subtitle: L10n.ourBaseRenditionWithStunningTonalityAndBeautifulColours,
				selected: viewStore.state == .chromatic(.tonachrome),
				iconXOffset: 0,
				iconYOffset: 0
			),
		])
	)
}

@ViewBuilder
public func grainPresenceOverlay(
	_ store: Store<OverlayFeature.State, OverlayFeature.Action>,
	viewStore: ViewStore<GrainPresence, CameraFeature.Action>
) -> some View {
	OverlayView(
		store: store,
		styling: .rows([
			.init(
				action: { viewStore.send(.setPreferredGrainPresence(.none)) },
				buttonColor: .init(hex: 0xF3F3F3),
				buttonOverlayColor: .init(.darkGray),
				image: .image(Asset.Phosphor.prohibitInset.swiftUIImage),
				title: L10n.grainless,
				subtitle: L10n.noGrainWillBePresentInTheImage,
				selected: viewStore.state == .none
			),
			.init(
				action: { viewStore.send(.setPreferredGrainPresence(.normal)) },
				buttonColor: .green,
				buttonOverlayColor: .white,
				image: .image(Asset.Phosphor.circlesThree.swiftUIImage),
				title: L10n.fineGrain,
				subtitle: L10n.subtleGrainProcedurallyGeneratedSimilarToTheKindFoundOnAnalogFilm,
				selected: viewStore.state == .normal
			),
			.init(
				action: { viewStore.send(.setPreferredGrainPresence(.high)) },
				buttonColor: .watermelon,
				buttonOverlayColor: .white,
				image: .image(Asset.Phosphor.circlesFour.swiftUIImage),
				title: L10n.pronouncedGrain,
				subtitle: L10n.coarseGrainProcedurallyGeneratedSimilarToTheKindFoundOnAnalogFilm,
				selected: viewStore.state == .high
			),
		])
	)
}

@ViewBuilder
public func cameraPermissionsOverlay(
	_ store: Store<OverlayFeature.State, OverlayFeature.Action>,
	_ cameraStore: StoreOf<CameraFeature>
) -> some View {
	OverlayView(
		store: store,
		styling: .view(AnyView(CameraPermissionsOverlayView(cameraStore)))
	)
}
