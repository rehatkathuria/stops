// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "Aesthetics",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Aesthetics",
			targets: ["Aesthetics"]
		),
	],
	dependencies: [
		.package(
			name: "ExtensionKit",
			path: "../ExtensionKit"
		),
	],
	targets: [
		.target(
			name: "Aesthetics",
			dependencies: [
				.product(
					name: "ExtensionKit",
					package: "ExtensionKit"
				),
			],
			resources: [
				.process("Resources")
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "AestheticsTests",
			dependencies: ["Aesthetics"]
		),
	]
)
