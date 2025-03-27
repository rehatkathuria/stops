import SwiftUI
#if !os(macOS)
import UIKit

public struct UIViewRepresented<UIViewType>: UIViewRepresentable where UIViewType: UIView {
	public let makeUIView: (Context) -> UIViewType
	public let updateUIView: (UIViewType, Context) -> Void = { _, _ in }

	public func makeUIView(context: Context) -> UIViewType {
		self.makeUIView(context)
	}

	public func updateUIView(_ uiView: UIViewType, context: Context) {
		self.updateUIView(uiView, context)
	}

	public init(_ make: @escaping (Context) -> UIViewType) { self.makeUIView = make }
}

#endif
