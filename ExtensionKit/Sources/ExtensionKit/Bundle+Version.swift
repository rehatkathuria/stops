import Foundation

public extension Bundle {
	private var releaseVersionNumber: String? {
		infoDictionary?["CFBundleShortVersionString"] as? String
	}
	var releaseVersion: String {
		"v\(releaseVersionNumber ?? "1.0.0")"
	}
}
