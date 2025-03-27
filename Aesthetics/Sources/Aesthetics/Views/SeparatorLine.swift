import ExtensionKit
import SwiftUI

@ViewBuilder
public func separator(_ theme: Theme) -> some View {
	let separatorPrimaryColor = Color.black
	let separatorSecondaryColor = Color(theme.cardBorderStripColor)
	
	ZStack(alignment: .center) {
		VStack(alignment: .center, spacing: 0) {
			Rectangle()
				.fill(separatorPrimaryColor)
				.frame(
					width: UIScreen.main.bounds.size.width,
					height: 2.0,
					alignment: .center
				)
			
			Rectangle()
				.fill(separatorSecondaryColor)
				.frame(
					width: UIScreen.main.bounds.size.width - 2.0,
					height: 1.0,
					alignment: .center
				)
		}
	}
	.frame(
		height: 4,
		alignment: .center
	)
}
