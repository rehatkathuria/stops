import Aesthetics
import AVFoundation.AVCaptureDevice
import CameraFeature
import ComposableArchitecture
import ExtensionKit
import Shared
import SwiftUI
import Views

public struct CameraControlsView: View {
	private var appStore: StoreOf<AppFeature>
	private var store: StoreOf<CameraFeature>
	@Environment(\.lacksPhysicalHomeButton) var lacksPhysicalHomeButton
	@Environment(\.layoutDirection) var nativeLayoutDirection
	@Environment(\.shutterStyle) var shutterStyle
	
	public struct ViewModel: Equatable {
		let iconRotation: Angle
		let preferredFlashMode: AVCaptureDevice.FlashMode
		let screen: Screen
		let shutterStyle: ShutterStyle
	}
	
	public init(_ appStore: StoreOf<AppFeature>, _ store: StoreOf<CameraFeature>) {
		self.appStore = appStore
		self.store = store
	}
	
	// MARK: - Views
	
	private func iconForFlashMode(_ flashMode: AVCaptureDevice.FlashMode) -> Image {
		switch flashMode {
		case .on: return Asset.PhosphorFill.lightningFill.swiftUIImage
		case .auto: return Asset.PhosphorFill.lightningAFill.swiftUIImage
		default: return Asset.PhosphorFill.lightningSlashFill.swiftUIImage
		}
	}
	
	@ViewBuilder
	private func controls() -> some View {
		WithViewStore(
			appStore,
			observe: { state in
				ViewModel(
					iconRotation: state.iconRotation,
					preferredFlashMode: state.camera.preferredFlashMode,
					screen: state.screen,
					shutterStyle: state.camera.shutterStyle
				)
			}
		) { viewModelStore in
			HStack {
				SquareButton(
					image: .image(Asset.PhosphorBold.circleDashedBold.swiftUIImage),
					backgroundColor: .watermelon,
					foregroundColor: .white
				) {
					ViewStore(store.stateless).send(.didRequestGrainPresencePresentation)
				}
				.rotationEffect(.degrees(90))
				.offset(y: viewModelStore.screen == .camera ? 0.0 : AppView.controlsOffset)
				.animation(.springable, value: viewModelStore.state)
				.rotationEffect(viewModelStore.iconRotation)
				.animation(.springable, value: viewModelStore.iconRotation)
				
				SquareButton(
					image: .image(Asset.PhosphorFill.eyedropperSampleFill.swiftUIImage),
					backgroundColor: .green,
					foregroundColor: .black,
					iconOffset: 0
				) {
					ViewStore(store.stateless).send(.didRequestQuantizationPreferencePresentation)
				}
				.offset(y: viewModelStore.screen == .camera ? 0.0 : AppView.controlsOffset)
				.animation(
					.springable.delay(viewModelStore.screen == .camera ? 0.025 : 0.0),
					value: viewModelStore.state
				)
				.rotationEffect(viewModelStore.iconRotation)
				.animation(.springable, value: viewModelStore.iconRotation)
				
				WithViewStore(store, observe: \.preferredQuantization) { quantizationStore in
					SquareButton(
						image: .image(Asset.Phosphor.bezierCurve.swiftUIImage),
						backgroundColor: .purple,
						foregroundColor: .white
					) {
						ViewStore(store.stateless).send(.didRequestQuantizatonAssociatedVariableIteration)
					}
					.opacity(
						quantizationStore.state.hasAssociatedVariable ? 1.0 : 0.0
					)
					.offset(y: viewModelStore.screen == .camera ? 0.0 : AppView.controlsOffset)
					.animation(
						.springable.delay(viewModelStore.screen == .camera ? 0.05 : 0.0),
						value: viewModelStore.screen
					)
					.rotationEffect(viewModelStore.iconRotation)
					.animation(.springable, value: viewModelStore.iconRotation)
				}

				Spacer()
				
				SquareButton(
					image: .image(iconForFlashMode(viewModelStore.preferredFlashMode)),
					backgroundColor: .init(hex: 0xF3B341),
					foregroundColor: .black,
					iconOffset: 0,
					imageScale: .large
				) {
					viewModelStore.send(.camera(.toggleFlashMode))
				}
				.offset(y: viewModelStore.screen == .camera ? 0.0 : AppView.controlsOffset)
				.animation(
					.springable
						.delay(viewModelStore.screen == .camera ? 0.075 : 0.0),
					value: viewModelStore.screen
				)
				.rotationEffect(viewModelStore.iconRotation)
				.animation(.springable, value: viewModelStore.iconRotation)

				SquareButton(
					image: .image(Asset.PhosphorFill.layoutFill.swiftUIImage),
					backgroundColor: .bubblegum,
					foregroundColor: .black,
					iconOffset: 0,
					imageScale: .large
				) {
					ViewStore(store.stateless).send(.didRequestAspectRatioOverlayPresentation)
				}
				.offset(y: viewModelStore.screen == .camera ? 0.0 : AppView.controlsOffset)
				.animation(
					.springable
						.delay(viewModelStore.screen == .camera ? 0.075 : 0.0),
					value: viewModelStore.screen
				)
				.rotationEffect(viewModelStore.iconRotation)
				.animation(.springable, value: viewModelStore.iconRotation)
				
				SquareButton(
					image: .image(Asset.PhosphorFill.gitDiffFill.swiftUIImage),
					backgroundColor: .blue,
					foregroundColor: .white,
					iconOffset: 0,
					imageScale: .large
				) {
					ViewStore(store.stateless).send(.toggleCameraPosition)
				}
				.offset(y: viewModelStore.screen == .camera ? 0.0 : AppView.controlsOffset)
				.animation(.springable, value: viewModelStore.screen)
				.rotationEffect(viewModelStore.iconRotation)
				.animation(.springable, value: viewModelStore.iconRotation)
			}
			.if(true) { view in
				WithViewStore(store) { viewStore in
					view
						.environment(
							\.layoutDirection,
							 viewStore.shouldReverseCameraControls
							 ? nativeLayoutDirection == .leftToRight
							 ? .rightToLeft
							 : .leftToRight
							 : nativeLayoutDirection
						)
				}
			}
			.padding()
			.padding(
				.top,
				lacksPhysicalHomeButton
					? 30
					: viewModelStore.shutterStyle == .dedicatedButton
						? 15
						: 0
			)
		}
	}
	
	public var body: some View {
		controls()
	}
}

struct CameraControlsView_Preview: PreviewProvider {
	static var previews: some View {
		let cameraFeatureState: CameraFeature.State = {
			var foo = CameraFeature.State(
				cameraPosition: .front,
				preferredAspectRatio: .oneByOne,
				preferredFlashMode: .on,
				preferredGrainPresence: .none,
				preferredQuantization: .chromatic(.tonachrome),
				screen: .camera
			)
			foo.cameraPermission = .allowed
			return foo
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

