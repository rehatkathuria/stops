import Foundation
import SwiftUI

public extension SwiftUI.Font {
	static func registerCustomFonts() {
		for url in Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? [] {
			CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
		}
		
		for url in Bundle.module.urls(forResourcesWithExtension: "otf", subdirectory: nil) ?? [] {
			CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
		}
	}
}

public extension View {
	func registerCustomFonts() -> Self {
		SwiftUI.Font.registerCustomFonts()
		return self
	}
}

