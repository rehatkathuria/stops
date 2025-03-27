import SwiftUI

public extension View {
	@ViewBuilder
	func `if`<Result: View>(_ condition: Bool, _ modifier: (Self) -> Result) -> some View {
		if condition {
			modifier(self)
		} else {
			self
		}
	}
}
