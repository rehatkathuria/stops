import Convenience
import UIKit
import Photos

class AssetTransitionItem: NSObject {
	var initialFrame: CGRect
	var image: UIImage {
		didSet {
			imageView?.image = image
		}
	}
	var indexPath: IndexPath
	var object: GalleryDisplayable
	var targetFrame: CGRect?
	var imageView: UIImageView?
	var touchOffset: CGVector = CGVector.zero
	
	init(
		initialFrame: CGRect,
		image: UIImage,
		indexPath: IndexPath,
		object: GalleryDisplayable
	) {
		self.initialFrame = initialFrame
		self.image = image
		self.indexPath = indexPath
		self.object = object
		super.init()
	}
}

protocol AssetTransitioning {
	func itemsForTransition(context: UIViewControllerContextTransitioning) -> Array<AssetTransitionItem>
	func targetFrame(transitionItem: AssetTransitionItem) -> CGRect?
	func willTransition(fromController: UIViewController, toController: UIViewController, items: Array<AssetTransitionItem>)
	func didTransition(fromController: UIViewController, toController: UIViewController, items: Array<AssetTransitionItem>)
}
