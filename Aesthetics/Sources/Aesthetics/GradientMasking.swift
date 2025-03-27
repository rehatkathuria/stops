import ExtensionKit
import SwiftUI

public extension View {
	@ViewBuilder func gradientForeground(_ styling: GradientStyling) -> some View {
		gradientForegroundMask([styling.topColor, styling.bottomColor])
	}
}
