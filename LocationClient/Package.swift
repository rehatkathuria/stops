// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "LocationClient",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "LocationClient",
			targets: ["LocationClient"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/AsyncSwift/AsyncLocationKit.git", .upToNextMinor(from: "1.6.1")),
		
		.package(name: "Preferences", path: "../Preferences"),
		.package(name: "Shared", path: "../Shared")
	],
	targets: [
		.target(
			name: "LocationClient",
			dependencies: [
				.product(name: "AsyncLocationKit", package: "AsyncLocationKit"),
				
				.product(name: "Preferences", package: "Preferences"),
				.product(name: "Shared", package: "Shared"),
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "LocationClientTests",
			dependencies: ["LocationClient"]
		),
	]
)
