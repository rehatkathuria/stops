import SwiftUI

#if os(macOS)
import Cocoa

public typealias UIImage = NSImage
public typealias UIScreen = NSScreen
public typealias UIColor = NSColor
public typealias UUID = NSUUID

public extension NSImage {
	var cgImage: CGImage? {
		var proposedRect = CGRect(
			origin: .zero,
			size: size
		)
		
		return cgImage(
			forProposedRect: &proposedRect,
			context: nil,
			hints: nil
		)
	}
}

public extension Optional where Wrapped == NSScreen {
	var scale: CGFloat {
		self?.backingScaleFactor ?? 1
	}
}

public extension Image {
	init(img: UIImage) {
		self.init(nsImage: img)
	}
}

#else

import UIKit

public extension Image {
	init(img: UIImage) {
		self.init(uiImage: img)
	}
}
#endif
