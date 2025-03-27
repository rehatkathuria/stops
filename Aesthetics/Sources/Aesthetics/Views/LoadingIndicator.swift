import Foundation
import SwiftUI

public struct LoadingIndicator: View {
	public var body: some View {
		Image(systemName: "sun.min.fill")
			.resizable()
			.blendMode(.difference)
			.rotationEffect(Angle(degrees: self.isAnimating ? 360.0 : 0.0))
			.animation(
				Animation
					.linear(duration: 12.0)
					.repeatForever(autoreverses: false),
				value: isAnimating
			)
			.onAppear {
				isAnimating = true
			}
	}
	
	@State var isAnimating = false
	
	public init() { }
}
