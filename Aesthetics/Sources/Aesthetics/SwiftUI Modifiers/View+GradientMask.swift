import SwiftUI

extension View {
	func gradientForegroundMask(_ colors: [Color]) -> some View {
		self.overlay(
			LinearGradient(
				gradient: Gradient(
					colors: colors
				),
				startPoint: .top,
				endPoint: .bottom
			)
		)
			.mask(self)
	}
}

