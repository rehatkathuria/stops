import AVFoundation
import ComposableArchitecture
import Foundation
import Pow
import SwiftUI
import Views

public struct LensAdjustmentView: View {
	
	// MARK: - Properties
	
	private let store: StoreOf<CameraFeature>
	
	@State private var contentsSize = CGSize.zero
	@State private var offsetX: CGFloat = 0
	@State private var offsetY: CGFloat = 0
	@State private var hasFiredOffLensAmendment = false
	
	@GestureState private var isFingerDown = false
	
	// MARK: - Init
	
	init(store: StoreOf<CameraFeature>) { self.store = store }
	
	// MARK: - View
	
	func layeredText(_ text: String) -> some View {
		ZStack {
			Text(text)
				.monospacedDigit()
				.kerning(-1)
				.foregroundColor(.white)
				.offset(y: 1)
			
			Text(text)
				.monospacedDigit()
				.kerning(-1)
				.foregroundColor(.black)
		}
	}
	
	@ViewBuilder
	func zoomSelectionView() -> some View {
		#if targetEnvironment(simulator)
		EmbossedText("0.5")
		#else
		WithViewStore(store) { viewStore in
			if let displayable = viewStore.zoomLevelDisplayable {
				switch displayable {
				case .string(let string): EmbossedText(string)
				case .image(let image): Image(uiImage: image)
				}
			}
		}
		#endif
	}
	
//	let textUpAndDownAnimation = Animation.spring(duration: 0.2, bounce: 0.4)
	let textUpAndDownAnimation = Animation.springable
	let lensPositioningUpwardsOffest = CGFloat(50)
	
	public var body: some View {
		ZStack {
			zoomSelectionView()
				.animation(textUpAndDownAnimation, value: isFingerDown)
				.offset(y: isFingerDown ? 0.0 : -lensPositioningUpwardsOffest)
			
			layeredText("—")
				.rotationEffect(.degrees(-45))
				.offset(x: -0.5, y: -0.5)
				.animation(textUpAndDownAnimation, value: isFingerDown)
				.offset(y: !isFingerDown ? 0.0 : lensPositioningUpwardsOffest)
		}
		.fixedSize()
		.frame(maxWidth: 25)
		.clipped()
		.background(
			Rectangle()
				.fill(Color.seaSalt)
				.cornerRadius(24)
				.shadow(
					color: Color(UIColor.black.withAlphaComponent(0.55)),
					radius: 2,
					x: 0,
					y: 1
				)
				.padding(-6)
				.padding(.horizontal, isFingerDown ? -10 : 0)
		)
//		.animation(.spring(duration: 0.35, bounce: 0.45), value: isFingerDown)
		.animation(.springable, value: isFingerDown)
		.gesture(
			DragGesture(minimumDistance: 0)
				.updating($isFingerDown) { (_, isFingerDown, _) in isFingerDown = true }
		)
		.simultaneousGesture(
			DragGesture(minimumDistance: 0, coordinateSpace: .global)
				.onChanged { value in
					let initialX = (value.location.x - value.startLocation.x)
					let initialY = (value.location.y - value.startLocation.y)
					
					offsetX = initialX * 0.75
					offsetY = (initialY * 0.90) - lensPositioningUpwardsOffest
					
					guard !hasFiredOffLensAmendment else { return }
					
					let half = UIScreen.main.bounds.width.half
					let percentage = offsetX / half
					
					if percentage > 0.5 {
						hasFiredOffLensAmendment = true
						ViewStore(store.stateless).send(.setZoom(.tighter))
					}
					else if percentage < -0.5 {
						hasFiredOffLensAmendment = true
						ViewStore(store.stateless).send(.setZoom(.wider))
					}
				}
				.onEnded { value in
					offsetX = 0
					offsetY = 0
					hasFiredOffLensAmendment = false
				}
		)
		.offset(x: offsetX, y: offsetY)
		.animation(
			.springable,
			value: isFingerDown
		)
		.boldThemedFont(size: 18)
		.onChange(of: isFingerDown) { value in
			ViewStore(store.stateless).send(
				value
					? .didBeginLensAmendmentGesture
					: .didEndLensAmendmentGesture
			)
		}
	}
}
