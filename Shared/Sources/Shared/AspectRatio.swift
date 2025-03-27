import Foundation

public enum AspectRatio: String {
	case fiveByFour
	case fourByThree
	case threeByTwo
	case oneByOne
	
	public var landscape: CGSize {
		switch self {
		case .fiveByFour: return .init(width: 5, height: 4)
		case .fourByThree: return .init(width: 4, height: 3)
		case .threeByTwo: return .init(width: 3, height: 2)
		case .oneByOne: return .init(width: 1, height: 1)
		}
	}
	
	public var portrait: CGSize {
		switch self {
		case .fiveByFour: return .init(width: 4, height: 5)
		case .fourByThree: return .init(width: 3, height: 4)
		case .threeByTwo: return .init(width: 2, height: 3)
		case .oneByOne: return .init(width: 1, height: 1)
		}
	}
}
