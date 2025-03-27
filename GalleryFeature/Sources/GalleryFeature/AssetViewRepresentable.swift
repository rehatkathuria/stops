import Combine
import ComposableArchitecture
import PermissionsClient
import Photos
import Preferences
import Shared
import SwiftUI
import UIKit


struct AssetViewRepresentable: UIViewRepresentable {

	// MARK: - Substructures
	
	typealias UIViewType = UIView
	
	// MARK: - Properties
	
	let store: StoreOf<GalleryFeature>
	let assetVC: AssetViewController
	
	// MARK: - Lifecycle
	
	init(
		store: StoreOf<GalleryFeature>,
		shutterStyle: ShutterStyle
	) {
		self.store = store
		self.assetVC = AssetViewController(
			layoutStyle: .grid,
			shutterStyle: shutterStyle,
			store: store
		)
	}
	
	// MARK: - UIViewRepresentable
	
	func makeUIView(context: Context) -> UIView {
		let nav = UINavigationController(rootViewController: assetVC)
		nav.navigationBar.isHidden = true
		navigationController = nav
		transitionController = AssetTransitionController(
			navigationController: nav,
			shutterStyle: assetVC.shutterStyle,
			store: store
		)
		navigationController?.delegate = transitionController
		guard let navigationController else { return .init(frame: .zero) }
		return navigationController.view
	}

	func updateUIView(_ uiView: UIView, context: Context) {
		assetVC.shutterStyle = context.environment.shutterStyle
		transitionController?.shutterStyle = context.environment.shutterStyle
	}
	
}
