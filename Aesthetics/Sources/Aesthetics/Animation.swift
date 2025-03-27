import Foundation
import SwiftUI

extension Animation {
	static public var springable: Animation {
		return .spring(
			response: 0.45,
			dampingFraction: 0.65
		)
	}
}
