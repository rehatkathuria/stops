import Combine
import CombineSchedulers
import ComposableArchitecture
import SwiftUI

public struct Schedulers {
	public var userInteractive: AnySchedulerOf<DispatchQueue>
	public var main: AnySchedulerOf<DispatchQueue>
}

private enum SchedulersKey: DependencyKey {
	static let liveValue: Schedulers = .live
	static var testValue: Schedulers = .init(
		userInteractive: .immediate.eraseToAnyScheduler(),
		main: .main
	)
}

public extension DependencyValues {
	var schedulers: Schedulers {
		get { self[SchedulersKey.self] }
		set { self[SchedulersKey.self] = newValue }
	}
}

private enum AVSchedulersKey: DependencyKey {
	static let liveValue: Schedulers = .av
	static var testValue: Schedulers = .init(
		userInteractive: .immediate.eraseToAnyScheduler(),
		main: .immediate.eraseToAnyScheduler()
	)
}

public extension DependencyValues {
	var avSchedulers: Schedulers {
		get { self[AVSchedulersKey.self] }
		set { self[AVSchedulersKey.self] = newValue }
	}
}


extension Schedulers {
	public static let live = Self(
		userInteractive: DispatchQueue.global(qos: .userInteractive).eraseToAnyScheduler(),
		main: .main
	)
	
	public static let av = Self(
		userInteractive: DispatchQueue(
			label: "com.eff.corp.aperture.schedulers.avcaptureclient.live",
			qos: .userInteractive
		).eraseToAnyScheduler(),
		main: .main
	)
}

extension Publisher {
	public func schedule(with schedulers: Schedulers, animation: Animation? = nil) -> AnyPublisher<Output, Failure> {
		self
			.subscribe(on: schedulers.userInteractive)
			.receive(on: schedulers.main.animation(animation))
			.eraseToAnyPublisher()
	}
}

extension Effect {
	public func schedule(with schedulers: Schedulers, animation: Animation? = nil) -> Effect<Output, Failure> {
		self
			.subscribe(on: schedulers.userInteractive)
			.receive(on: schedulers.main.animation(animation))
			.eraseToEffect()
	}
}
