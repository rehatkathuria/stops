// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "Preferences",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Preferences",
			targets: ["Preferences"]
		),
	],
	dependencies: [
		.package(name: "Shared", path: "../Shared"),
	],
	targets: [
		.target(
			name: "Preferences",
			dependencies: [
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
			name: "PreferencesTests",
			dependencies: ["Preferences"]
		),
	]
)
