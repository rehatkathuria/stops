import Aesthetics
import Foundation
import SwiftUI

#if !os(macOS)
import UIKit
#endif

public enum CallToAction {
	case text(String)
	case image(String)
	case swiftImage(Image)
}

public struct ChunkyButtonConfiguration {
	let callToAction: CallToAction
	let callToActionHidden: Bool
	let cornerRadius: CGFloat
	let intention: GradientStyling
	let size: CGFloat
	
	public init(
		callToAction: CallToAction,
		callToActionHidden: Bool,
		cornerRadius: CGFloat,
		intention: GradientStyling,
		size: CGFloat
	) {
		self.callToAction = callToAction
		self.callToActionHidden = callToActionHidden
		self.cornerRadius = cornerRadius
		self.intention = intention
		self.size = size
	}
}

public struct ChunkyButton: View {
	public static let defaultHeight = CGFloat(54)
	public let height: CGFloat

	let configuration: ChunkyButtonConfiguration
	let tapAction: () -> Void
	let longPressDownAction: (() -> Void)?
	let longPressUpAction: (() -> Void)?
	let minWidth: CGFloat?
	
	@GestureState private var isFingerDown = false
	
	public init(
		_ intention: GradientStyling = .primary,
		_ callToAction: CallToAction,
		callToActionHidden: Bool = false,
		cornerRadius: CGFloat = 18,
		size: CGFloat = 18,
		minWidth: CGFloat? = nil,
		height: CGFloat = ChunkyButton.defaultHeight,
		longPressDownAction: (() -> Void)? = nil,
		longPressUpAction: (() -> Void)? = nil,
		_ tapAaction: @escaping () -> Void
	) {
		self.configuration = .init(
			callToAction: callToAction,
			callToActionHidden: callToActionHidden,
			cornerRadius: cornerRadius,
			intention: intention,
			size: size
		)
		self.tapAction = tapAaction
		self.longPressDownAction = longPressDownAction
		self.longPressUpAction = longPressUpAction
		self.minWidth = minWidth
		self.height = height
	}
	
	@ViewBuilder private func callToAction() -> some View {
		switch configuration.callToAction {
		case .text(let string):
			ZStack {
				Text(string)
					.foregroundColor(.white)
					.opacity(0.65)
				
				Text(string)
			}
		case .image(let systemName):
			Image(systemName: systemName)
				.foregroundColor(configuration.intention.foregroundColor)
		case .swiftImage(let image):
			ZStack {
				image
					.resizable()
					.renderingMode(.template)
					.aspectRatio(contentMode: .fit)
					.foregroundColor(.white)
					.opacity(0.65)
					.offset(y: 0.65)
				
				image
					.resizable()
					.renderingMode(.template)
					.foregroundColor(configuration.intention.foregroundColor)
					.aspectRatio(contentMode: .fit)
			}
			.frame(height: height)
		}
	}
	
	public var body: some View {
		callToAction()
			.opacity(configuration.callToActionHidden ? 0 : 1)
			.foregroundColor(configuration.intention.foregroundColor)
			.boldThemedFont(size: configuration.size)
			.padding(.vertical, 10)
			.padding(.horizontal, 20)
			.frame(height: height)
			.frame(minWidth: minWidth)
			.background(
				LinearGradient(
					gradient: Gradient(
						colors: [
							configuration.intention.topColor,
							configuration.intention.bottomColor
						]
					),
					startPoint: .top,
					endPoint: .bottom
				)
			)
			.cornerRadius(configuration.cornerRadius)
			.shadow(
				color: isFingerDown ? .clear : Color(UIColor.black.withAlphaComponent(0.55)),
				radius: 2,
				x: 0,
				y: 1
			)
			.fixedSize()
			.gesture(
				DragGesture(minimumDistance: 0)
					.updating($isFingerDown) { (_, isFingerDown, _) in isFingerDown = true }
			)
			.simultaneousGesture(
				TapGesture(count: 1)
					.onEnded { _ in
						tapAction()
					}
					.simultaneously(
						with: LongPressGesture()
							.onEnded({ _ in longPressDownAction?() })
					)
			)
			.onChange(of: isFingerDown) { newValue in
				guard newValue == false else { return }
				longPressUpAction?()
			}
	}
}
