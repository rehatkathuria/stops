import SwiftUI

public extension View {
	func frame(dimension: CGFloat?, alignment: Alignment = .center) -> some View {
		frame(width: dimension, height: dimension, alignment: alignment)
	}

	func frame(size: CGSize) -> some View {
		frame(width: size.width, height: size.height)
	}
	
	func extendFrame(_ axes: Axis.Set = [.horizontal, .vertical], alignment: Alignment = .center) -> some View {
		frame(
			maxWidth: axes.contains(.horizontal) ? .infinity : nil,
			maxHeight: axes.contains(.vertical) ? .infinity : nil,
			alignment: alignment
		)
	}

	#if canImport(UIKit)
	func growToFitMainScreen(_ axes: Axis.Set = [.horizontal, .vertical], alignment: Alignment = .center) -> some View {
		frame(
			width: axes.contains(.horizontal) ? UIScreen.main.bounds.size.width : nil,
			height: axes.contains(.vertical) ? UIScreen.main.bounds.size.height : nil,
			alignment: alignment
		)
	}
	#endif
}
