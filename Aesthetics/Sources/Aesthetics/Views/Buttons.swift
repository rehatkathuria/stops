import ExtensionKit
import Foundation
import SwiftUI

#if !os(macOS)
import UIKit
#endif

public enum CallToAction {
	case text(String)
	case image(String)
}

public struct ButtonConfiguration {
	let callToAction: CallToAction
	let cornerRadius: CGFloat
	let intention: GradientStyling
	let size: CGFloat
}

public struct Button: View {
	let configuration: ButtonConfiguration
	
	public init(
		_ intention: GradientStyling = .primary,
		_ callToAction: CallToAction,
		cornerRadius: CGFloat = 20,
		size: CGFloat = 20.0
	) {
		self.configuration = .init(
			callToAction: callToAction,
			cornerRadius: cornerRadius,
			intention: intention,
			size: size
		)
	}
	
	@ViewBuilder private func callToAction() -> some View {
		switch configuration.callToAction {
		case .text(let string):
			ZStack {
				Text(string)
					.foregroundColor(.white)
					.opacity(0.65)
					.offset(x: 0, y: 0.75)
				
				Text(string)
			}
		case .image(let systemName):
			Image(systemName: systemName)
				.foregroundColor(configuration.intention.foregroundColor)
		}
	}
	
	public var body: some View {
		callToAction()
			.foregroundColor(configuration.intention.foregroundColor)
			.boldThemedFont(size: configuration.size)
			.padding(.vertical, 10)
			.padding(.horizontal, 20)
			.background(
				LinearGradient(
					gradient: Gradient(
						colors: [
							configuration.intention.topColor,
							configuration.intention.bottomColor
						]
					),
					startPoint: .top,
					endPoint: .bottom
				)
			)
			.cornerRadius(configuration.cornerRadius)
			.shadow(
				color: Color(UIColor.black.withAlphaComponent(0.55)),
				radius: 2,
				x: 0,
				y: 1
			)
			.frame(maxHeight: 38)
			.fixedSize()
	}
}
