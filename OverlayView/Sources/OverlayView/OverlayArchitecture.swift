import Foundation
import ComposableArchitecture
import Haptics

public struct OverlayFeature: ReducerProtocol {
	public static let teardownDuration = DispatchQueue.SchedulerTimeType.Stride.milliseconds(350)
	
	public struct State: Equatable {
		public var isActive: Bool = false
		public var isForefront: Bool = false
		public init() {
			self.isActive = true
			self.isForefront = true
		}
	}

	public enum Action: Equatable {
		case didRequestDismissal
		case didRequestFlickDismissal
		case setDismissed
	}

	@Dependency(\.hapticClient) private var hapticClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.schedulers) private var schedulers
	
	public init() { }
	
	public var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			core(state: &state, action: action)
		}
	}
	
	func core(state: inout State, action: Action) -> EffectTask<Action> {
		func dismissEffect() -> EffectTask<Action> {
			.init(value: .setDismissed)
				.delay(for: OverlayFeature.teardownDuration, scheduler: mainQueue)
				.schedule(with: schedulers)
				.eraseToEffect()
		}
		
		switch action {
		case .didRequestDismissal:
			state.isActive = false
			return .merge(
				hapticClient.rigidImpact(0.5).fireAndForget(),
				dismissEffect()
			)

		case .didRequestFlickDismissal:
			state.isActive = false
			return dismissEffect()
			
		case .setDismissed:
			state.isForefront = false
			return .none
			
		}
	}
}
