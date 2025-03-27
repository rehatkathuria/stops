import SwiftUI

public extension View {
	func frame(dimension: CGFloat?) -> some View {
		frame(width: dimension, height: dimension)
	}

	func frame(size: CGSize) -> some View {
		frame(width: size.width, height: size.height)
	}

	func maxSizeInfinity() -> some View {
		frame(
			maxWidth: .infinity,
			maxHeight: .infinity
		)
	}
}
