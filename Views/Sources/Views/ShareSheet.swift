import Foundation
import SwiftUI

public struct ShareSheet: UIViewControllerRepresentable {
	let activityItems: [Any]
	let completionHandler: (Bool) -> ()
	
	public init(
		activityItems: [Any],
		completionHandler: @escaping (Bool) -> ()
	) {
		self.activityItems = activityItems
		self.completionHandler = completionHandler
	}
	
	public func makeUIViewController(context: Context) -> UIActivityViewController {
		let viewController = UIActivityViewController(
			activityItems: activityItems,
			applicationActivities: nil
		)
		viewController.completionWithItemsHandler = { _, didComplete, _, _ in
			completionHandler(didComplete)
		}
		return viewController
	}
	
	public func updateUIViewController(
		_ uiViewController: UIActivityViewController,
		context: Context
	) { }
}
