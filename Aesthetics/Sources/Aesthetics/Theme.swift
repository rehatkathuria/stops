import ExtensionKit
import Foundation
import SwiftUI

#if !os(macOS)
import UIKit
#endif

public let theme = Theme()

public class Theme: Equatable, ObservableObject {
	public static func == (lhs: Theme, rhs: Theme) -> Bool {
		return
			lhs.accentPrimaryColor == rhs.accentPrimaryColor
			&& lhs.accentPrimaryShadowColor == rhs.accentPrimaryShadowColor
			&& lhs.cameraGridOverlayColor == rhs.cameraGridOverlayColor
			&& lhs.cardBorderBackgroundColor == rhs.cardBorderBackgroundColor
			&& lhs.cardBorderStripColor == rhs.cardBorderStripColor
			&& lhs.cardInnerContainerBackgroundColor == rhs.cardInnerContainerBackgroundColor
	}

	// MARK: - Card

	public var cardBorderBackgroundColor = UIColor.black

	public var cardBorderStripColor = UIColor(red: 64.0/255.0, green: 68.0/255.0, blue: 71.0/255.0, alpha: 1.0)

	public var cardInnerContainerBackgroundColor = UIColor(red: 37.0/255.0, green: 41.0/255.0, blue: 45.0/255.0, alpha: 1.0)

	public var cameraGridOverlayColor: UIColor {
		UIColor.white.withAlphaComponent(0.65)
	}

	// Siblings.

	public var cardNavigationTitleColor: UIColor {
		return .white
	}

	// MARK: - Accents

	public var accentPrimaryColor: UIColor {
		.init(red: 3.0/255.0, green: 193.0/255.0, blue: 108.0/255.0, alpha: 1.0)
	}

	public var accentPrimaryShadowColor: UIColor {
		.init(red: 0.0/255.0, green: 50.0/255.0, blue: 13.0/255.0, alpha: 1.0)
	}

// MARK: - Buttons

	public var primaryButtonBackgroundColor: UIColor {
		return .init(red: 255.0/255.0, green: 2.0/255.0, blue: 84.0/255.0, alpha: 1.0)
	}

	public var primaryButtonTitleColor: UIColor {
		return .white
	}

	public init() { }
}

private struct ThemeKey: EnvironmentKey {
	static public let defaultValue = Theme()
}

public extension EnvironmentValues {
	var theme: Theme {
		get { self[ThemeKey.self] }
		set { self[ThemeKey.self] = newValue }
	}
}
