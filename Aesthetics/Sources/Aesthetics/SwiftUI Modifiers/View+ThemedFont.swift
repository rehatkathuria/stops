import SwiftUI

public extension View {
	func boldThemedFont(size: CGFloat) -> some View {
		self
			.font(.custom(FontFamily.CircularStd.bold, size: size))
	}
	
	func mediumThemedFont(size: CGFloat) -> some View {
		self
			.font(.custom(FontFamily.CircularStd.medium, size: size))
	}
	
	func themedFont(size: CGFloat) -> some View {
		self
			.font(.custom("Circular Std", size: size))
	}
}
