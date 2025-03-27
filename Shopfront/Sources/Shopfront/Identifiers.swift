import Foundation
import StoreKit

extension Product {
	public struct Pro {
		public static let monthly = "com.eff.corp.aperture.pro.onemonthly"
		public static let yearly = "com.eff.corp.aperture.pro.oneyearly"
	}
	
	static let identifiers: [String] = [
		Product.Pro.monthly,
		Product.Pro.yearly
	]
}
