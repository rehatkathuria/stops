import Foundation
import SwiftUI

public struct SquareButton: View {
	
	public indirect enum Image {
		case systemName(String)
		case image(SwiftUI.Image)
	}
	
	public indirect enum ImageScale {
		case small
		case medium
		case large
		case extraLarge
	}
	
	@GestureState private var isFingerDown = false
	
	private let image: Image
	private let backgroundColor: Color
	private let foregroundColor: Color
	private let iconOffset: CGFloat
	private let iconSize: CGFloat
	private let imageScale: ImageScale
	
	private var dimension: CGFloat {
		switch imageScale {
		case .small: return iconSize * 0.5
		case .medium: return iconSize * 0.5
		case .large: return iconSize * 0.6
		case .extraLarge: return iconSize * 0.7
		}
	}
	
	private let action: () -> Void
	
	public init(
		image: Image,
		backgroundColor: Color = .red,
		foregroundColor: Color,
		iconOffset: CGFloat = 0.5,
		iconSize: CGFloat = 40,
		imageScale: ImageScale = .large,
		_ action: @escaping () -> Void
	) {
		self.image = image
		self.backgroundColor = backgroundColor
		self.foregroundColor = foregroundColor
		self.iconOffset = iconOffset
		self.iconSize = iconSize
		self.imageScale = imageScale
		self.action = action
	}
	
	// MARK: - View
	
	public var body: some View {
		ZStack {
			SwiftUI.Image("squarebuttonshadow")
				.resizable()
				.frame(width: iconSize + 8, height: iconSize + 8, alignment: .center)
			
			RoundedRectangle(
				cornerRadius: 9,
				style: .circular
			)
			.fill(backgroundColor)
			.frame(width: iconSize, height: iconSize, alignment: .center)

			Group {
				switch image {
				case .systemName(let systemName): SwiftUI.Image(systemName: systemName)
				case .image(let image):
					image
						.renderingMode(.template)
						.resizable()
						.frame(dimension: dimension)
				}
			}
				.foregroundColor(foregroundColor)
//				.imageScale(imageScale)
		}
		.frame(width: iconSize, height: iconSize, alignment: .center)
		.gesture(
			DragGesture(minimumDistance: 0)
				.updating($isFingerDown) { (_, isFingerDown, _) in
					isFingerDown = true
				}
		)
		.simultaneousGesture(
			TapGesture(count: 1)
				.onEnded({ _ in action() })
		)
	}
	
}
