import Foundation
import Photos
import UIKit

let imageManager: PHCachingImageManager = {
	let new = PHCachingImageManager()
	new.allowsCachingHighQualityImages = false
	return new
}()

let backgroundManager = PHCachingImageManager.default()
var navigationController: UINavigationController?

var assetsHolder: AssetsHolder!
var bottomSafeArea: CGFloat {
//	#if !CAPTURE_EXTENSION
//	UIApplication.shared.windows.first?.rootViewController?.view.safeAreaInsets.bottom ?? 0
//	#else
	0
//	#endif
}
var transitionController: AssetTransitionController?
