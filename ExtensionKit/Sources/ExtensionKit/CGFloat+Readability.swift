#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension CGFloat {
	var oneTenth: CGFloat { return self * 0.10 }
	var twoTenths: CGFloat { return self * 0.20 }
	var quarter: CGFloat { return self * 0.25 }
	var threeTenths: CGFloat { return self * 0.30 }
	var fourTenths: CGFloat { return self * 0.40 }
	var half: CGFloat { return self * 0.5 }
	var sixTenths: CGFloat { return self * 0.60 }
	var sevenTenths: CGFloat { return self * 0.70 }
	var threeQuarters: CGFloat { return self * 0.75 }
	var eightTenths: CGFloat { return self * 0.80 }
	var nineTenths: CGFloat { return self * 0.90 }
	var double: CGFloat { return self * 2.0 }
}
