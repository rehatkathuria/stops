import Foundation

public enum Either<Left, Right> {
	case left(Left)
	case right(Right)
	
	var isLeft: Bool { left != nil }
	
	var left: Left? {
		get {
			guard case let .left(inner) = self else { return nil }
			return inner
		}
		set {
			guard let newValue = newValue else { return }
			self = .left(newValue)
		}
	}
	
	var isRight: Bool { right != nil }
	
	var right: Right? {
		get {
			guard case let .right(inner) = self else { return nil }
			return inner
		}
		set {
			guard let newValue = newValue else { return }
			self = .right(newValue)
		}
	}
}

// MARK: - Identifiable

extension Either: Identifiable where Left: Identifiable, Right: Identifiable {
	public var id: AnyHashable {
		switch self {
		case let .left(inner):
			return inner.id
		case let .right(inner):
			return inner.id
		}
	}
}

// MARK: - Equatable

extension Either: Equatable where Left: Equatable, Right: Equatable {
	public static func == (lhs: Either<Left, Right>, rhs: Either<Left, Right>) -> Bool {
		switch (lhs, rhs) {
		case let (.left(lhsInner), .left(rhsInner)):
			return lhsInner == rhsInner
		case let (.right(lhsInner), .right(rhsInner)):
			return lhsInner == rhsInner
		default:
			return false
		}
	}
}

// MARK: - Hashabble

extension Either: Hashable where Left: Hashable, Right: Hashable {
	public func hash(into hasher: inout Hasher) {
		switch self {
		case .left(let value):
			value.hash(into: &hasher)
		case .right(let value):
			value.hash(into: &hasher)
		}
	}
}
