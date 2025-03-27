import Aesthetics
import ComposableArchitecture
import Foundation
import Shared
import StoreKit

public struct ShopfrontFeature: ReducerProtocol {
	public struct State: Equatable {
		public internal(set) var attemptedToCapture: UIImage?
		public internal(set) var attemptedCaptureQuantization: Quantization
		public internal(set) var products: IdentifiedArrayOf<Product>
		public internal(set) var page: ProBenefits
		public internal(set) var selected: Product?
		
		public internal(set) var attemptingToCheckout: Bool = false
		
		public let shouldAllowExamplesIteration: Bool
		
		public init(
			attemptedToCapture: UIImage? = nil,
			attemptedCaptureQuantization: Quantization = .monochrome,
			page: ProBenefits
		) {
			self.attemptedToCapture = attemptedToCapture
			self.attemptedCaptureQuantization = attemptedCaptureQuantization
			self.shouldAllowExamplesIteration = attemptedToCapture == nil
			self.products = .init(uniqueElements: [])
			self.selected = nil
			self.page = page
			self.attemptingToCheckout = false
		}
	}

	public enum Action: Equatable {
		case load
		case handleLoad(IdentifiedArrayOf<Product>)
		
		case purchaseSelected
		case handlePurchaseResult(Product.PurchaseResult)
		
		case select(Product)
		case setPage(ProBenefits)
		
		case iterateQuantizationExample
	}

	@Dependency(\.hapticClient) private var hapticClient
	@Dependency(\.shopfrontClient) private var shopfrontClient
	@Dependency(\.mainQueue) private var mainQueue
	
	public init() { }
	
	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			core(state: &state, action: action)
		}
	}
	
	func core(state: inout State, action: Action) -> EffectTask<Action> {
		struct ProductsFetchID: Hashable { }
		
		switch action {
		case .load:
			return .task {
				_ = try await shopfrontClient.hasActiveSubscription()
				let products = try await shopfrontClient.loadProducts()
				return .handleLoad(.init(uniqueElements: products))
			}
			
		case .handleLoad(let result):
			state.products = .init(uniqueElements: result)
			if state.selected == nil {
				state.selected = result.first(where: { $0.id == Product.Pro.monthly })
			}
			return .none
			
		case .purchaseSelected:
			guard let selected = state.selected else { return .none }
			state.attemptingToCheckout = true
			return .concatenate(
				.merge(
					hapticClient.prepare().fireAndForget(),
					hapticClient.impact().fireAndForget()
				),
				.task {
					let value = try await shopfrontClient.purchase(selected)
					return .handlePurchaseResult(value)
				}
			)
			
		case .handlePurchaseResult(let result):
			state.attemptingToCheckout = false
			switch result {
			case .success: ShopfrontClient.shared.hasActiveSubscription = true
			default: break
			}
			return .none
			
		case .select(let product):
			guard state.attemptingToCheckout == false else { return .none }
			state.selected = product
			return .none
			
		case .setPage(let page):
			state.page = page
			return .none
			
		case .iterateQuantizationExample:
			switch state.attemptedCaptureQuantization {
			case .chromatic(.folia): state.attemptedCaptureQuantization = .chromatic(.supergold)
			case .chromatic(.supergold): state.attemptedCaptureQuantization = .monochrome
			case .monochrome:
				state.attemptedCaptureQuantization = .warhol(.glowInTheDark)
				state.attemptedCaptureQuantization = .chromatic(.folia)
				#warning("Temporarily ignoring the quirky quantization here")
				
			default: state.attemptedCaptureQuantization = .chromatic(.folia)
			}
			return .merge(
				hapticClient.prepare().fireAndForget(),
				 hapticClient.impact().fireAndForget()
			 )
			
		}
	}
}

extension Product.PurchaseResult: Equatable {
	public static func == (lhs: Product.PurchaseResult, rhs: Product.PurchaseResult) -> Bool {
		switch (lhs, rhs) {
		case (.success(let lhsVerification), .success(let rhsVerification)):
			return lhsVerification.jwsRepresentation == rhsVerification.jwsRepresentation
		case (.pending, .pending): return true
		case (.userCancelled, .userCancelled): return true
		default: return false
		}
	}
}
