import Aesthetics
import Combine
import ComposableArchitecture
import MediaPlayer
import Preferences
import Shared
import SwiftUI
import UIKit

public struct TabbedViewControllerRepresentable: UIViewControllerRepresentable {
	public typealias UIViewControllerType = TabbedViewController
	private let navigationView: () -> AnyView
	private let bodyView: () -> AnyView
	private let tabView: () -> AnyView
	private let tabAccessoriesView: () -> AnyView
	
	public init(
		navigationView: @escaping () -> AnyView,
		bodyView: @escaping () -> AnyView,
		tabView: @escaping () -> AnyView,
		tabAccessoriesView: @escaping () -> AnyView
	) {
		self.navigationView = navigationView
		self.bodyView = bodyView
		self.tabView = tabView
		self.tabAccessoriesView = tabAccessoriesView
	}
	
	// MARK: - UIViewRepresentable

	public func makeUIViewController(context: Context) -> TabbedViewController {
		TabbedViewController(
			navigationView: navigationView,
			bodyView: bodyView,
			tabView: tabView,
			tabAccessoriesView: tabAccessoriesView
		)
	}

	public func updateUIViewController(_ uiViewController: TabbedViewController, context: Context) {
		uiViewController.mainContainer.layer.cornerRadius = context.environment.isPresentingSheet
			? 8.0
			:	UIScreen.main.displayCornerRadius
		
		if uiViewController.shutterStyle != context.environment.shutterStyle {
			uiViewController.shutterStyle = context.environment.shutterStyle
			uiViewController.view.setNeedsLayout()
			uiViewController.view.layoutIfNeeded()
		}
	}
}

public final class TabbedViewController: UIViewController {

	// MARK: - Properties

	let mainContainer = UIView()

	// MARK: - Properties (Private)

	var shutterStyle: ShutterStyle = .dedicatedButton
	
	private let topContainer = UIView()
	private let bottomContainer = UIView()
	private let tabAccessoriesContainer = UIView()
	private let childrenViewControllersContainer = UIView()
	private let childrenNavigationViewControllersContainer = UIView()

	private let topCardSeparator = CardViewSeparator()
	private let bottomSeparator = CardViewSeparator()

	private var bottomSeparatorConstraint: NSLayoutConstraint?
	private var bottomContainerConstraint: NSLayoutConstraint?
	private var cancellables = Set<AnyCancellable>()

	private let stackView = UIView()
	private var selectedTab: Int?

	private var theme = Theme()

	private let navigationHostingController: UIViewController
	private let bodyHostingController: UIViewController
	private let tabHostingController: UIViewController
	private let tabAccessoriesController: UIViewController
	
	// MARK: - Lifecycle

	public init(
		navigationView: () -> AnyView,
		bodyView: () -> AnyView,
		tabView: () -> AnyView,
		tabAccessoriesView: () -> AnyView
	) {
		let navController = UIHostingController(rootView: navigationView())
		navigationHostingController = navController
		navigationHostingController.view.clipsToBounds = true
		
		let bodyController = UIHostingController(rootView: bodyView())
		bodyHostingController = bodyController
		
		let tabController = UIHostingController(rootView: tabView())
		tabHostingController = tabController
		
		let tabAccessoriesViewController = UIHostingController(rootView: tabAccessoriesView())
		tabAccessoriesController = tabAccessoriesViewController
		
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	public required init?(coder: NSCoder) { fatalError() }

	// MARK: - View Lifecycle
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		let navController = navigationHostingController
		let bodyController = bodyHostingController
		let tabController = tabHostingController
		let tabAccessoriesViewController = tabAccessoriesController
		
		mainContainer.layer.cornerCurve = .continuous

		[
			mainContainer,
			topCardSeparator,
			bottomSeparator,
			bottomContainer,
			childrenViewControllersContainer,
			childrenNavigationViewControllersContainer,
			topContainer,
			tabAccessoriesContainer
		]
		.forEach({ iterating in
			view.addSubview(iterating)
		})

		bottomContainer.addSubview(stackView)

		childrenViewControllersContainer.backgroundColor = theme.cardInnerContainerBackgroundColor

		navController.willMove(toParent: self)
		addChild(navController)
		navController.view.backgroundColor = theme.cardInnerContainerBackgroundColor
		
		bodyController.willMove(toParent: self)
		addChild(bodyController)
		bodyController.view.backgroundColor = theme.cardInnerContainerBackgroundColor
		
		tabController.willMove(toParent: self)
		addChild(tabController)
		tabController.view.backgroundColor = .clear
		
		tabAccessoriesViewController.willMove(toParent: self)
		addChild(tabAccessoriesViewController)
		tabAccessoriesViewController.view.backgroundColor = .clear
		
		topContainer.addSubview(navController.view)
		navController.didMove(toParent: self)
		
		childrenViewControllersContainer.addSubview(bodyController.view)
		bodyController.didMove(toParent: self)
		
		stackView.addSubview(tabController.view)
		tabController.didMove(toParent: self)
		
		tabAccessoriesContainer.addSubview(tabAccessoriesViewController.view)
		tabAccessoriesViewController.didMove(toParent: self)

		view.backgroundColor = theme.cardBorderStripColor
		mainContainer.backgroundColor = theme.cardInnerContainerBackgroundColor
		bottomSeparator.backgroundColor = theme.cardBorderBackgroundColor
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let topContainerSize = CGFloat(50)
		let bottomContainerSize = shutterStyle.bottomBarHeight
		
		/// MARK: - Top
		
		topContainer.frame = .init(
			origin: .init(
				x: 0,
				y: view.safeAreaInsets.top
			),
			size: .init(
				width: view.bounds.width - 4,
				height: topContainerSize
			)
		)
		topContainer.center = .init(
			x: view.center.x,
			y: topContainer.center.y
		)
		
		topCardSeparator.frame = .init(
			origin: .init(
				x: 0,
				y: topContainer.frame.maxY
			),
			size: .init(
				width: view.bounds.width,
				height: cardViewSeparatorPreferredHeight
			)
		)
		
		navigationHostingController.view.frame = topContainer.bounds
		
		mainContainer.frame = .init(
			origin: .zero,
			size: .init(
				width: view.bounds.width - 2.5,
				height: view.bounds.height - 2.5
			)
		)
		mainContainer.center = .init(
			x: view.bounds.width.half,
			y: view.bounds.height.half - 0.25
		)
		
		let hasNoBottomAreaSafeInset = view.safeAreaInsets.bottom == 0
		
		bottomSeparator.frame = .init(
			origin: .init(
				x: 0,
				y: (view.bounds.height - view.safeAreaInsets.bottom)
				 - (bottomContainerSize + (hasNoBottomAreaSafeInset ? 28 : 5))
			),
			size: .init(
				width: view.bounds.width,
				height: cardViewSeparatorPreferredHeight
			)
		)
		
		bottomContainer.frame = .init(
			origin: .init(
				x: 2.5,
				y: bottomSeparator.frame.maxY
			),
			size: .init(
				width: view.bounds.width - 5,
				height: view.bounds.height - bottomSeparator.frame.maxY
			)
		)
		
		let childrensContainerHeight = bottomSeparator.frame.minY - topCardSeparator.frame.maxY
		let childrensContainerWidth = view.bounds.width - 4
		childrenViewControllersContainer.frame = .init(
			origin: .init(
				x: view.bounds.width.half - childrensContainerWidth.half,
				y: bottomSeparator.frame.minY - childrensContainerHeight
			),
			size: .init(
				width: childrensContainerWidth,
				height: childrensContainerHeight
			)
		)

		tabAccessoriesContainer.frame = .init(
			origin: .zero,
			size: .init(
				width: childrenViewControllersContainer.bounds.width,
				height: ChunkyButton.defaultHeight
			)
		)
		tabAccessoriesContainer.center = bottomSeparator.center

		childrenNavigationViewControllersContainer.frame = .init(
			origin: .zero,
			size: .init(
				width: topContainer.bounds.width - 15,
				height: topContainer.bounds.height
			)
		)
		childrenNavigationViewControllersContainer.center = topContainer.center
		
		stackView.frame.size = bottomContainer.bounds.size
		navigationHostingController.view.frame = topContainer.bounds
		bodyHostingController.view.frame = childrenViewControllersContainer.bounds
		tabHostingController.view.frame = bottomContainer.bounds
		tabAccessoriesController.view.frame.size = tabAccessoriesContainer.frame.size
	}
	
}
