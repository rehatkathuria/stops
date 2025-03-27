import ExtensionKit
import Foundation
import SwiftUI

public struct AnthillView: View {
	@State private var phase: CGFloat = 0
	private let color: Color
	
	public init(color: Color) {
		self.color = color
	}
	
	public var body: some View {
		Rectangle()
			.strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10], dashPhase: phase))
			.foregroundColor(color)
			.onAppear {
				withAnimation(.linear.repeatForever(autoreverses: false)) {
					phase += 20
				}
			}
	}
}
