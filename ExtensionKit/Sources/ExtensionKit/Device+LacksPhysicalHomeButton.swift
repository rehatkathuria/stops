import Foundation
import SwiftUI
import UIKit

private struct LacksPhysicalHomeButton: EnvironmentKey {
	static public let defaultValue = UIDevice.current.lacksPhysicalHomeButton
}

public extension EnvironmentValues {
	var lacksPhysicalHomeButton: Bool {
		get { self[LacksPhysicalHomeButton.self] }
		set { self[LacksPhysicalHomeButton.self] = newValue }
	}
}

extension UIDevice {
	var lacksPhysicalHomeButton: Bool {
//		#if !CAPTURE_EXTENSION
//		if #available(iOS 13.0, *) {
//			let scenes = UIApplication.shared.connectedScenes
//			let windowScene = scenes.first as? UIWindowScene
//			guard let window = windowScene?.windows.first else { return false }
//			
//			return window.safeAreaInsets.top > 20
//		}
//		
//		if #available(iOS 11.0, *), UIApplication.shared.windows.indices.contains(0)  {
//			return UIApplication.shared.windows[0].safeAreaInsets.top > 20
//		} else {
//			// Fallback on earlier versions
//			return false
//		}
//		#else
			return true
//		#endif
	}
}
