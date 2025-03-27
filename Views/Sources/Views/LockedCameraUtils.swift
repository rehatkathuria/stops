import AVKit
import Foundation
import SwiftUI

@available(iOS 17.2, *)
private struct CaptureInteractionView: UIViewRepresentable {
	var action: () -> Void
	
	func makeUIView(context: Context) -> some UIView {
		let uiView = UIView()
		let interaction = AVCaptureEventInteraction { event in
			if event.phase == .began { action() }
		}
		uiView.addInteraction(interaction)
		return uiView
	}
	
	func updateUIView(_ uiView: UIViewType, context: Context) { }
}

public extension View {
	@ViewBuilder
	func onPressCapture(
		action: @escaping () -> Void
	) -> some View {
		if #available(iOS 17.2, *) {
			self.background {
				CaptureInteractionView(action: action)
			}
		} else {
			self
		}
	}
}
