import ComposableArchitecture
import Foundation

public extension Effect {
	static func resultTask(
		priority: TaskPriority? = nil,
		operation: @escaping @Sendable () async -> Result<Output, Failure>
	) -> Self {
		Effect<Result<Output, Failure>, Never>
			.task(priority: priority, operation: operation)
			.flatMap { result -> Self in
				switch result {
				case .success(let value): return Effect(value: value)
				case .failure(let error): return Effect(error: error)
				}
			}
			.eraseToEffect()
	}
}
