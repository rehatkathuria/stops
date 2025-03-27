import Aesthetics
import ComposableArchitecture
import Pow
import Shared
import SwiftUI
import Views

public struct CameraPermissionsView: View {
	
	private var store: StoreOf<CameraFeature>
	
	public init(_ store: StoreOf<CameraFeature>) {
		self.store = store
	}
	
	public var body: some View {
		VideoView(
			url: Bundle.module.url(forResource: "cropped", withExtension: "mov")!,
			isPlaying: true,
			isMuted: true
		)
		.border(Color.seaSalt, width: 4)
		.padding()
	}
}

public struct CameraPermissionsOverlayView: View {
	
	@State var tapTicker = UUID()
	
	private var store: StoreOf<CameraFeature>
	
	public init(_ store: StoreOf<CameraFeature>) {
		self.store = store
	}
	
	public var body: some View {
		VStack {
			Spacer()
			
			WithViewStore(store.scope(state: \.cameraPermission)) { permissionStore in
				SquareButton(
					image: .image(
						permissionStore.state == .denied
							? Asset.Phosphor.warningDiamond.swiftUIImage
							: Asset.Phosphor.videoCamera.swiftUIImage
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
			
			Text(L10n.cameraPermissions)
				.titleStyling
			
			Text(L10n.WeRequireCameraAccessToAllowYouToTakePhotos.tapTheButtonBelowToGetStarted)
				.subtitleStyling
			
			Spacer()
			
			ChunkyButton(.primary, .text(L10n.grantPermissions), height: 45) {
				tapTicker = .init()
				ViewStore(store.stateless).send(.requestCameraPermission)
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
