import Aesthetics
import Combine
import ExtensionKit
import SwiftUI
import UIKit

public struct CardView<Content: View, Navigation: View>: UIViewControllerRepresentable {
	public typealias UIViewControllerType = UIViewController
	
	private let viewController = UIViewController(nibName: nil, bundle: nil)
	private let cardView = CardViewUIKit()
	private let navigationChild: UIViewController
	private let contentChild: UIViewController
	
	private var cancellables = Set<AnyCancellable>()
	
	public init(
		@ViewBuilder navigation: @escaping () -> Navigation,
		@ViewBuilder content: @escaping () -> Content
	) {
		let contentHosting = UIHostingController(rootView: content())
		contentHosting.view.clipsToBounds = true
		
		let navigationHosting = UIHostingController(rootView: navigation())
		navigationHosting.view.clipsToBounds = true
		
		self.contentChild = contentHosting
		self.navigationChild = navigationHosting
		
		[
			contentHosting,
			navigationHosting
		]
			.forEach ({ controller in
				controller.view.backgroundColor = .clear
				controller.view.translatesAutoresizingMaskIntoConstraints = false
				viewController.addChild(controller)
				controller.willMove(toParent: viewController)
				cardView.addSubview(controller.view)
				controller.didMove(toParent: viewController)
			})
		
		cardView.translatesAutoresizingMaskIntoConstraints = false
		viewController.view.addSubview(cardView)
		
		NSLayoutConstraint.activate([
			navigationHosting.view.leadingAnchor.constraint(equalTo: cardView.topContainerView.leadingAnchor),
			navigationHosting.view.trailingAnchor.constraint(equalTo: cardView.topContainerView.trailingAnchor),
			navigationHosting.view.topAnchor.constraint(equalTo: cardView.topContainerView.topAnchor),
			navigationHosting.view.bottomAnchor.constraint(equalTo: cardView.topContainerView.bottomAnchor),

			contentHosting.view.widthAnchor.constraint(equalTo: cardView.bottomContainerView.widthAnchor, constant: -8),
			contentHosting.view.bottomAnchor.constraint(equalTo: cardView.bottomContainerView.bottomAnchor),
			contentHosting.view.topAnchor.constraint(equalTo: cardView.bottomContainerView.topAnchor),
			contentHosting.view.centerXAnchor.constraint(equalTo: cardView.bottomContainerView.centerXAnchor),
			
			cardView.widthAnchor.constraint(equalTo: viewController.view.widthAnchor),
			cardView.heightAnchor.constraint(equalTo: viewController.view.heightAnchor),
			cardView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
			cardView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
		])
	}
	
	public func makeUIViewController(context: Context) -> UIViewController { viewController }
	
	public func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

public let cardViewSeparatorPreferredHeight = CGFloat(3.0)
public let edgeToCardPadding = CGFloat(8)
public let edgeToInnerContainerPadding = CGFloat(6)

public final class CardViewSeparator: UIView {

	private let top = UIView()
	private let bottom = UIView()

	public override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = theme.cardBorderBackgroundColor
		top.backgroundColor = theme.cardBorderBackgroundColor
		bottom.backgroundColor = theme.cardBorderStripColor
		
		[
			top,
			bottom
		]
		.forEach({ view in
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		})

		NSLayoutConstraint.activate([
			top.widthAnchor.constraint(equalTo: widthAnchor),
			top.heightAnchor.constraint(equalToConstant: 2),
			top.bottomAnchor.constraint(equalTo: bottom.topAnchor),

			bottom.widthAnchor.constraint(equalTo: widthAnchor),
			bottom.heightAnchor.constraint(equalToConstant: 1),
			bottom.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	@available(*, unavailable)
	public required init?(coder: NSCoder) { fatalError() }
}

public final class CardViewUIKit: UIView {

	// MARK: - Typealiases

	public typealias UIViewType = CardView

	// MARK: - Properties

	public let topContainerView = UIView()
	public let bottomContainerView = UIView()

	// MARK: - Properties (Private)

	private let overallBlackBackgroundView = UIView()

	private let topBackgroundView = UIView()
	private let topSeparator = CardViewSeparator()
	private let topBackgroundViewStripHidingView = UIView()

	private let bottomBackgroundView = UIView()
	private let bottomBackgroundViewStripHidingView = UIView()

	private var cancellables = Set<AnyCancellable>()

	private var theme = Theme()

	// MARK: - Lifecycle

	public init() {
		super.init(frame: .zero)

		self.overallBlackBackgroundView.backgroundColor = theme.cardBorderBackgroundColor
		self.topBackgroundView.backgroundColor = theme.cardInnerContainerBackgroundColor
		self.bottomBackgroundView.backgroundColor = theme.cardInnerContainerBackgroundColor
		self.bottomBackgroundViewStripHidingView.backgroundColor = theme.cardInnerContainerBackgroundColor
		self.topBackgroundViewStripHidingView.backgroundColor = theme.cardInnerContainerBackgroundColor
		self.topContainerView.backgroundColor = theme.cardInnerContainerBackgroundColor
		self.topBackgroundView.layer.borderColor = theme.cardBorderStripColor.cgColor
		self.bottomBackgroundView.layer.borderColor = theme.cardBorderStripColor.cgColor
		self.setNeedsDisplay()

		[
			overallBlackBackgroundView,
			topBackgroundView,
			bottomBackgroundView,
			topSeparator,
			topContainerView,
			bottomContainerView,
			bottomBackgroundViewStripHidingView,
			topBackgroundViewStripHidingView
		].forEach({ view in
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		})

		let stripSize = CGFloat(1)
		let cornerRadiusSize = CGFloat(8)

		topBackgroundView.layer.cornerRadius = cornerRadiusSize
		topBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		topBackgroundView.layer.borderWidth = stripSize
		bottomBackgroundView.layer.borderWidth = stripSize

		topContainerView.clipsToBounds = true
		
		NSLayoutConstraint.activate([
			overallBlackBackgroundView.widthAnchor.constraint(equalTo: widthAnchor),
			overallBlackBackgroundView.heightAnchor.constraint(equalTo: heightAnchor),
			overallBlackBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
			overallBlackBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),

			topBackgroundView.widthAnchor.constraint(equalTo: overallBlackBackgroundView.widthAnchor, constant: -edgeToCardPadding.half),
			topBackgroundView.heightAnchor.constraint(equalToConstant: 55),
			topBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
			topBackgroundView.topAnchor.constraint(equalTo: overallBlackBackgroundView.topAnchor, constant: 2),

			topSeparator.widthAnchor.constraint(equalTo: topBackgroundView.widthAnchor),
			topSeparator.heightAnchor.constraint(equalToConstant: cardViewSeparatorPreferredHeight),
			topSeparator.topAnchor.constraint(equalTo: topBackgroundView.bottomAnchor),
			topSeparator.centerXAnchor.constraint(equalTo: centerXAnchor),

			bottomBackgroundView.topAnchor.constraint(equalTo: topSeparator.bottomAnchor),
			bottomBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
			bottomBackgroundView.widthAnchor.constraint(equalTo: topBackgroundView.widthAnchor),
			bottomBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),

			topContainerView.widthAnchor.constraint(
				equalTo: overallBlackBackgroundView.widthAnchor,
				constant: -40
			),
			topContainerView.centerXAnchor.constraint(equalTo: topBackgroundView.centerXAnchor),
			topContainerView.topAnchor.constraint(
				equalTo: topBackgroundView.topAnchor,
				constant: 1.5
			),
			topContainerView.bottomAnchor.constraint(
				equalTo: topBackgroundView.bottomAnchor,
				constant: -1
			),

			bottomContainerView.widthAnchor.constraint(equalTo: overallBlackBackgroundView.widthAnchor),
			bottomContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
			bottomContainerView.topAnchor.constraint(equalTo: topSeparator.bottomAnchor),
			bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

			bottomBackgroundViewStripHidingView.widthAnchor.constraint(
				equalTo: bottomContainerView.widthAnchor,
				constant: -((edgeToCardPadding * 0.5) + (stripSize * 2.0))
			),
			bottomBackgroundViewStripHidingView.topAnchor.constraint(
				equalTo: bottomContainerView.topAnchor
			),
			bottomBackgroundViewStripHidingView.heightAnchor.constraint(
				equalToConstant: stripSize
			),
			bottomBackgroundViewStripHidingView.centerXAnchor.constraint(
				equalTo: centerXAnchor
			),

			topBackgroundViewStripHidingView.widthAnchor.constraint(equalTo: bottomContainerView.widthAnchor, constant: -((edgeToCardPadding * 0.5) + (stripSize * 2.0))),
			topBackgroundViewStripHidingView.bottomAnchor.constraint(equalTo: topSeparator.topAnchor),
			topBackgroundViewStripHidingView.heightAnchor.constraint(equalToConstant: stripSize),
			topBackgroundViewStripHidingView.centerXAnchor.constraint(equalTo: centerXAnchor)
		])

		topContainerView.layer.cornerRadius = 6
		topContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

		bottomBackgroundView.layer.cornerCurve = .continuous
		bottomBackgroundView.layer.cornerRadius = UIScreen.main.displayCornerRadius
		bottomBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
	}

	@available(*, unavailable)
	public required init?(coder: NSCoder) { fatalError() }
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		bringSubviewToFront(bottomBackgroundViewStripHidingView)
		bringSubviewToFront(topBackgroundViewStripHidingView)
	}

	deinit { cancellables.forEach({ $0.cancel() }) }
}

