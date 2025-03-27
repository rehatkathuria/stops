import Foundation
import SwiftUI

public struct EmbossedText: View {
	
	private let text: String
	
	public init(_ text: String) { self.text = text }
	
	public var body: some View {
		ZStack {
			Text(text)
				.foregroundColor(.white)
				.offset(y: 1)
			
			Text(text)
				.foregroundColor(.black)
		}
	}
}
