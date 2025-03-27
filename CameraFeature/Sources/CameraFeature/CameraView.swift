import Aesthetics
import AVCaptureClient
import AVKit
import Combine
import ComposableArchitecture
import Shared
import SwiftUI
import Views

public struct CameraView: View {
	private var store: StoreOf<CameraFeature>

	@ObservedObject var model = ImageUpdater.shared
	
	@State var redactedSize = CGSize.zero
	
	public init(_ store: StoreOf<CameraFeature>) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			Group {
				if viewStore.isCurrentQuantizationRestricted {
					Rectangle()
						.fill(Color.clear)
						.extendFrame()
						.overlay {
							ZStack {
								if let _ = model.redactedPreviewImage {
									Image(uiImage: model.redactedPreviewImage ?? .init())
										.resizable()
										.scaledToFit()
										.border(.white, width: 4)
										.onSizeChange { size in
											guard redactedSize != size else { return }
											redactedSize = size
										}
										.padding()
								}
								
								if let _ = model.previewImage {
									PrivateImageView(
										frame: .init(origin: .zero, size: redactedSize),
										image: model.previewImage,
										contentMode: .resizeAspect
									)
									.padding()
								}
								
								if let _ = model.redactedPreviewImage, let _ = model.previewImage {
									Color.clear
										.frame(width: redactedSize.width, height: redactedSize.height)
										.border(.white, width: 4)
								}
							}
							.gestureControls(viewStore)
						}
				}
				else {
					Rectangle()
						.fill(Color.clear)
						.extendFrame()
						.overlay(item: model.previewImage) { image in
							Image(uiImage: image)
								.resizable()
								.scaledToFit()
								.border(.white, width: 4)
								.overlay {
									Rectangle()
										.fill(Color.black)
										.opacity(viewStore.captureFlashFired ? 0.80 : 0.0)
								}
								.gestureControls(viewStore)
								.padding()
						}
				}
			}
//			.overlay(alignment: .bottom) {
//				Color.clear.overlay {
//					VStack {
//						Spacer()
//						Spacer()
//						Spacer()
//						Spacer()
//						Spacer()
//						Spacer()
//						
//						LensAdjustmentView(store: store)
//						
//						Spacer()
//					}
//				}
//			}
			.overlay {
				HardwareViewRepresentable(store: store)
					.frame(dimension: 1)
			}
			.opacity(
				viewStore.cameraPermissionsNotGranted
					? 0
					: 1
			)
			.overlay(
				isShown: viewStore.cameraPermissionsNotGranted
			) {
				CameraPermissionsView(store)
					.onTapGesture {
						viewStore.send(.didRequestCameraPermissionsOverlayPresentation)
					}
			}
			.onAppear {
				viewStore.send(.didAppear)
			}
			.onDisappear {
				viewStore.send(.didDisappear)
			}
		}
	}
}

extension View {
	@ViewBuilder
	func gestureControls(_ viewStore: ViewStoreOf<CameraFeature>) -> some View {
		self
			.onTapGesture(count: 1) {
				guard viewStore.shutterStyle == .viewfinder else { return }
				viewStore.send(.didPressShutter(.photo))
			}
			.simultaneousGesture(
				TapGesture(count: 2)
					.onEnded { _ in
						guard viewStore.shutterStyle == .dedicatedButton else { return }
						viewStore.send(.toggleCameraPosition)
					}
			)
	}
}

public struct HardwareViewRepresentable: UIViewRepresentable {
	public typealias UIViewType = HardwareView
	
	private var store: StoreOf<CameraFeature>
	
	public init(store: StoreOf<CameraFeature>) {
		self.store = store
	}
	
	public func makeUIView(context: Context) -> HardwareView {
		.init(frame: .zero, store: store)
	}
	
	public func updateUIView(_ uiView: HardwareView, context: Context) { }
}

public final class HardwareView: UIView {
	private var eventInteraction: AVCaptureEventInteraction?
	private var store: StoreOf<CameraFeature>
	
	public init(
		frame: CGRect,
		store: StoreOf<CameraFeature>
	) {
		self.store = store
		super.init(frame: .zero)
		let interaction = AVCaptureEventInteraction { [weak self] event in
			guard 
				let self,
				event.phase == .ended
			else { return }
			
			ViewStore(self.store.stateless).send(.didPressShutter(.photo))
		}
		addInteraction(interaction)
		eventInteraction = interaction
	}
	
	@available(*, unavailable)
	public required init?(coder: NSCoder) { fatalError() }
}
