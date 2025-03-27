// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "PermissionsClient",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "PermissionsClient",
			targets: ["PermissionsClient"]
		),
	],
	dependencies: [
		.package(name: "Shared", path: "../Shared"),
	],
	targets: [
		.target(
			name: "PermissionsClient",
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
			name: "PermissionsClientTests",
			dependencies: ["PermissionsClient"]
		),
	]
)
