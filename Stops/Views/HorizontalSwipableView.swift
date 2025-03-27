import CameraFeature
import Combine
import ComposableArchitecture
import Foundation
import GalleryFeature
import Shared
import SwiftUI
import UIKit
import VolumeButtonInteractor

public let didRequestNavigationToCameraNotification = Notification.Name(
	rawValue: "com.eff.corp.aperture.didRequestNavigationToCameraNotification"
)
public let didRequestNavigationToGalleryNotification = Notification.Name(
	rawValue: "com.eff.corp.aperture.didRequestNavigationToGalleryNotification"
)

internal final class HorizontalSwipableViewController: UIViewController, UIScrollViewDelegate {
	
	// MARK: - Properties (Private)
	
	
	private let store: StoreOf<AppFeature>
	private let scrollView: UIScrollView
	
	private let cameraHostingController: UIHostingController<CameraView>
	private let galleryHostingController: UIHostingController<GalleryView>
	
	private let screenViewStore: ViewStore<Screen, AppFeature.Action>
	
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - Lifecycle
	
	public init(store: StoreOf<AppFeature>, frame: CGRect) {
		self.store = store
		self.scrollView = .init(frame: frame)
		self.cameraHostingController = .init(
			rootView: CameraView(
				store.scope(
					state: \.camera,
					action: AppFeature.Action.camera
				)
			)
		)
		self.galleryHostingController = .init(
			rootView: GalleryView(
				store: store.scope(
				 state: \.gallery, action:
					 AppFeature.Action.gallery
			 )
		 )
		)

		self.screenViewStore = ViewStore(store, observe: \.screen)
		
		super.init(nibName: nil, bundle: nil)

		scrollView.delegate = self
		
		cameraHostingController.view.backgroundColor = .clear
		galleryHostingController.view.backgroundColor = .clear
		
		scrollView.backgroundColor = .clear
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		
		view.addSubview(scrollView)
		
		addChild(cameraHostingController)
		scrollView.addSubview(cameraHostingController.view)
		cameraHostingController.didMove(toParent: self)
		
		addChild(galleryHostingController)
		scrollView.addSubview(galleryHostingController.view)
		galleryHostingController.didMove(toParent: self)
		
		NotificationCenter.default.addObserver(
			forName: didRequestNavigationToCameraNotification,
			object: nil,
			queue: .main
		) { notification in
			self.scrollView.setContentOffset(.zero, animated: true)
		}
		
		NotificationCenter.default.addObserver(
			forName: didRequestNavigationToGalleryNotification,
			object: nil,
			queue: .main
		) { notification in
			self.scrollView.setContentOffset(.init(x: self.view.bounds.width, y: 0), animated: true)
		}
		
		ViewStore(store, observe: \.isHorizontalSwipeEnabled)
			.publisher
			.sink { isHorizontalSwipeEnabled in
				self.scrollView.isScrollEnabled = isHorizontalSwipeEnabled
				self.scrollView.panGestureRecognizer.isEnabled = isHorizontalSwipeEnabled
			}
			.store(in: &cancellables)
		
		view.setNeedsLayout()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) { fatalError() }
	
	// MARK: - View Lifecycle
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		scrollView.frame = view.bounds
		scrollView.center = view.center
		scrollView.contentSize = .init(width: view.bounds.width.double, height: view.bounds.height)

		cameraHostingController.view.frame = view.bounds
		galleryHostingController.view.frame = view.bounds.offsetBy(dx: view.bounds.width, dy: 0)
	}
	
	// MARK: - UIScrollViewDelegate

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		setNeedsUpdatePaging(scrollView.contentOffset.x)
	}
	
	private func setNeedsUpdatePaging(_ offset: CGFloat) {
		if offset >= scrollView.bounds.width.half {
			if screenViewStore.state != .shoebox { screenViewStore.send(.setScreen(.shoebox)) }
		}
		else {
			if screenViewStore.state != .camera { screenViewStore.send(.setScreen(.camera)) }
		}
	}
}

internal struct HorizontalSwipableViewRepresentable: UIViewControllerRepresentable {
	typealias UIViewControllerType = HorizontalSwipableViewController

	private let store: StoreOf<AppFeature>
	private let frame: CGRect

	public init(store: StoreOf<AppFeature>, frame: CGRect) {
		self.store = store
		self.frame = frame
	}
	
	func makeUIViewController(context: Context) -> HorizontalSwipableViewController {
		.init(store: store, frame: frame)
	}

	func updateUIViewController(_ uiViewController: HorizontalSwipableViewController, context: Context) { }
	
}
