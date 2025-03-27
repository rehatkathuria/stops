// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "Views",
	platforms: [
		.iOS(.v16),
		.macOS(.v12),
	],
	products: [
		.library(
			name: "Views",
			targets: ["Views"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/stokatyan/ScrollCounter", branch: "master"),
		
		.package(name: "Aesthetics", path: "../Aesthetics"),
		.package(name: "Preferences", path: "../Preferences"),
	],
	targets: [
		.target(
			name: "Views",
			dependencies: [
				.product(name: "ScrollCounter", package: "ScrollCounter"),
				
				.product(name: "Aesthetics", package: "Aesthetics"),
				.product(name: "Preferences", package: "Preferences"),
			],
			swiftSettings: [
				.unsafeFlags(["-Xfrontend", "-application-extension"])
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
		),
		.testTarget(
			name: "ViewsTests",
			dependencies: ["Views"]
		),
	]
)
