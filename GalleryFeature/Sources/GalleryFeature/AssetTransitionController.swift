import ComposableArchitecture
import Shared
import UIKit

let assetTransitionDuration = 0.3

class AssetTransitionController: NSObject {
	weak var navigationController: UINavigationController?
	var operation: UINavigationController.Operation = .none
	var transitionDriver: AssetTransitionDriver?
	var initiallyInteractive = false
	var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
	var shutterStyle: ShutterStyle
	let store: StoreOf<GalleryFeature>
	
	init(navigationController: UINavigationController, shutterStyle: ShutterStyle, store: StoreOf<GalleryFeature>) {
		self.navigationController = navigationController
		self.store = store
		self.shutterStyle = shutterStyle
		super.init()
		
		navigationController.delegate = self
		configurePanGestureRecognizer()
	}
	
	func configurePanGestureRecognizer() {
		panGestureRecognizer.delegate = self
		panGestureRecognizer.maximumNumberOfTouches = 1
		panGestureRecognizer.addTarget(self, action: #selector(initiateTransitionInteractively(_:)))
		navigationController?.view.addGestureRecognizer(panGestureRecognizer)
		
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		
		guard
			let interactivePopGestureRecognizer = navigationController?.interactivePopGestureRecognizer
		else { return }
		
		panGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
	}
	
	@objc func initiateTransitionInteractively(_ panGesture: UIPanGestureRecognizer) {
		if panGesture.state == .began && transitionDriver == nil {
			initiallyInteractive = true
			let _ = navigationController?.popViewController(animated: true)
		}
	}
}

extension AssetTransitionController: UIGestureRecognizerDelegate {
	func gestureRecognizer(
		_ gestureRecognizer: UIGestureRecognizer,
		shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
	) -> Bool { false }
	
	func gestureRecognizerShouldBegin(
		_ gestureRecognizer: UIGestureRecognizer
	) -> Bool {
		guard
			let transitionDriver = self.transitionDriver
		else {
			let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
			let translationIsVertical = (translation.y > 0) && (abs(translation.y) > abs(translation.x))
			return translationIsVertical && (navigationController?.viewControllers.count ?? 0 > 1)
		}
		
		return transitionDriver.isInteractive
	}
}

extension AssetTransitionController: UINavigationControllerDelegate {
	func navigationController(
		_ navigationController: UINavigationController,
		animationControllerFor operation: UINavigationController.Operation,
		from fromVC: UIViewController,
		to toVC: UIViewController
	) -> UIViewControllerAnimatedTransitioning? {
		self.operation = operation
		return self
	}
	
	func navigationController(
		_ navigationController: UINavigationController,
		interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
	) -> UIViewControllerInteractiveTransitioning? { self }
}

extension AssetTransitionController: UIViewControllerInteractiveTransitioning {
	func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
		transitionDriver = AssetTransitionDriver(
			operation: operation,
			context: transitionContext,
			panGestureRecognizer: panGestureRecognizer,
			shutterStyle: shutterStyle,
			store: store
		)
	}
	
	var wantsInteractiveStart: Bool { initiallyInteractive }
}

extension AssetTransitionController: UIViewControllerAnimatedTransitioning {
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		assetTransitionDuration
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { }
	
	func animationEnded(_ transitionCompleted: Bool) {
		transitionDriver = nil
		initiallyInteractive = false
		operation = .none
	}
	
}
