import SwiftUI

public struct SealCheckmark: View {
	public var body: some View {
		ZStack {
			Image(systemName: "seal.fill")
				.resizable()
				.frame(dimension: 25)
				.foregroundColor(.green)
				.blendMode(.difference)
		
			Image(systemName: "checkmark")
				.resizable()
				.font(Font.title.weight(.black))
				.frame(dimension: 10)
		}
	}
	
	public init() { }
}
