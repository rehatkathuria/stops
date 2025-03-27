import Combine
import ComposableArchitecture
import Foundation
import Pow
import Shared
import StoreKit

public final class ShopfrontClient: NSObject, ObservableObject, SKPaymentTransactionObserver {

	// MARK: - Properties
	
	public static let shared = ShopfrontClient()
	@Published public var hasActiveSubscription = false
	
	public var transactions: AnyPublisher<Transaction, Never> {
		transactionsPassback.eraseToAnyPublisher()
	}
	
	private let transactionsPassback = PassthroughSubject<Transaction, Never>()
	private var longLivedListener: Task.Handle<Void, Never>?
	
	// MARK: - Lifecycle
	
	private override init() {
		unlockPow(reason: .iDidBuyTheLicense)
		
		super.init()
		
		longLivedListener = .detached {
			for await result in Transaction.updates {
				switch result {
				case .verified(let verified):
					self.transactionsPassback.send(verified)
				case .unverified: break
				}
			}
		}
	}
	
	// MARK: - StoreKit Interaction
	
	public func purchase(_ product: Product) async throws -> Product.PurchaseResult {
		do {
			let result = try await product.purchase()
			return result
		}
		catch let error {
			throw error
		}
	}
	
	public func loadProducts() async throws -> [Product] {
		try await Product.products(for: Product.identifiers)
	}

	public func hasActiveSubscription() async throws -> Bool {
		if ShopfrontClient.shared.hasActiveSubscription { return true }
				
		for await result in Transaction.currentEntitlements {
			switch result {
			case .verified:
				DispatchQueue.main.async {
					ShopfrontClient.shared.hasActiveSubscription = true
				}
				return true
			case .unverified: continue
			}
		}
		return false
	}
	
	// MARK: - SKPaymentTransactionObserver
	
	public func paymentQueue(
		_ queue: SKPaymentQueue,
		updatedTransactions transactions: [SKPaymentTransaction]
	) {
		transactions.forEach { transaction in
			guard
				transaction.transactionState == .purchased || transaction.transactionState == .restored
			else { return }
			queue.finishTransaction(transaction)
			DispatchQueue.main.async {
				ShopfrontClient.shared.hasActiveSubscription = true
			}
		}
	}

}
