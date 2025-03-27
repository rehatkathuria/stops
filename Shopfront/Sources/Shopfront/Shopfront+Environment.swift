import ComposableArchitecture
import Foundation

private enum ShopfrontClientKey: DependencyKey {
	static let liveValue: ShopfrontClient = ShopfrontClient.shared
	static var testValue: ShopfrontClient = ShopfrontClient.shared
}

public extension DependencyValues {
	var shopfrontClient: ShopfrontClient {
		get { self[ShopfrontClientKey.self] }
		set { self[ShopfrontClientKey.self] = newValue }
	}
}

