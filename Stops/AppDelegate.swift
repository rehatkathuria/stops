import Foundation
import Shopfront
import StoreKit
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
	
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
	) -> Bool {
		SKPaymentQueue.default().add(ShopfrontClient.shared)
		return true
	}
	
	func applicationWillTerminate(
		_ application: UIApplication
	) {
		SKPaymentQueue.default().remove(ShopfrontClient.shared)
	}

}
