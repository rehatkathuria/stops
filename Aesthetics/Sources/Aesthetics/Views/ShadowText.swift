import Foundation
import SwiftUI

public struct ShadowText: View {
	
	let string: String
	let shadowColor: Color
	
	public init(_ string: String, _ shadowColor: Color) {
		self.string = string
		self.shadowColor = shadowColor
	}
	
	public var body: some View {
		ZStack {
			Text(string)
				.offset(y: 1.5)
				.foregroundColor(shadowColor)
			
			Text(string)
		}
	}
}
