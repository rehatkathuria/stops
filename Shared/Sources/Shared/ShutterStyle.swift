import Foundation
import SwiftUI

public enum ShutterStyle: String, Equatable {
	case dedicatedButton
	case viewfinder
	
	public var bottomBarHeight: CGFloat {
		switch self {
		case .dedicatedButton: return 75
		case .viewfinder: return 60
		}
	}
	
	public var bottomBarTransitionOffset: CGFloat {
		switch self {
		case .dedicatedButton: return 73
		case .viewfinder: return 73
		}
	}
}

private struct ShutterStyleKey: EnvironmentKey {
	static public let defaultValue = ShutterStyle.dedicatedButton
}

public extension EnvironmentValues {
	var shutterStyle: ShutterStyle {
		get { self[ShutterStyleKey.self] }
		set { self[ShutterStyleKey.self] = newValue }
	}
}
