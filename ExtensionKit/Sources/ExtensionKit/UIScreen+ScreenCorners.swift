#if !os(macOS)
import UIKit

// https://github.com/kylebshr/ScreenCorners/blob/main/Sources/ScreenCorners/UIScreen%2BScreenCorners.swift
public extension UIScreen {
	private static let cornerRadiusKey: String = {
		let components = ["Radius", "Corner", "display", "_"]
		return components.reversed().joined()
	}()

	/// The corner radius of the display. Uses a private property of `UIScreen`,
	/// and may report 0 if the API changes.
	var displayCornerRadius: CGFloat {
		guard let cornerRadius = self.value(forKey: Self.cornerRadiusKey) as? CGFloat else {
			return 0
		}
		return cornerRadius
	}
}

#endif
