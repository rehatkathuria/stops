import Foundation
import SwiftUI

public struct IsPresentingSheet: EnvironmentKey {
	static public let defaultValue = Bool(false)
}

public extension EnvironmentValues {
	var isPresentingSheet: Bool {
		get { self[IsPresentingSheet.self] }
		set { self[IsPresentingSheet.self] = newValue }
	}
}
