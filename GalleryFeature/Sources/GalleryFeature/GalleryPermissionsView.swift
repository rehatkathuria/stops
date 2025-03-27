import Aesthetics
import ComposableArchitecture
import Pow
import Shared
import SwiftUI
import Views

public struct GalleryPermissionsView: View {
	
	@State var tapTicker = UUID()
	
	private var store: StoreOf<GalleryFeature>
	
	public init(_ store: StoreOf<GalleryFeature>) {
		self.store = store
	}
	
	public var body: some View {
		VStack {
			Spacer()
			
			WithViewStore(store.scope(state: \.permissionState)) { permissionStore in
				SquareButton(
					image: .image(
						permissionStore.state == .denied
							? Asset.Phosphor.warningDiamond.swiftUIImage
							: Asset.Phosphor.images.swiftUIImage
					),
					backgroundColor: permissionStore.state == .denied
							? .orange
							: .seaSalt,
					foregroundColor: .black,
					iconOffset: 0,
					iconSize: 45
				) { }
			}
			.padding(.bottom, 15)
			
			Text(L10n.galleryPermissions)
				.titleStyling
			
			Text(L10n.WeRequireGalleryPermissionToAllowYouToViewAndSavePhotos.tapTheButtonBelowToGetStarted)
				.subtitleStyling
			
			Spacer()
			
			ChunkyButton(.primary, .text(L10n.grantPermissions), height: 45) {
				tapTicker = .init()
				ViewStore(store.stateless).send(.requestPermissions)
			}
				.changeEffect(
					.pulse(
						shape: RoundedRectangle(
							cornerRadius: 14,
							style: .circular
						),
						drawingMode: .fill,
						count: 3
					),
					value: tapTicker
				)
		}
		.frame(minHeight: 250)
		.extendFrame(.horizontal)
		.fixedSize(horizontal: false, vertical: true)
		.padding()
		.padding(.horizontal)
		.padding(.bottom)
	}
}

fileprivate extension View {
	var titleStyling: some View {
		self
			.foregroundColor(.white)
			.boldThemedFont(size: 18)
			.multilineTextAlignment(.leading)
	}
	
	var subtitleStyling: some View {
		self
			.foregroundColor(Color(.lightGray))
			.themedFont(size: 14)
			.multilineTextAlignment(.center)
			.fixedSize(horizontal: false, vertical: true)
	}
}
