// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Changeset",
	products: [
		.library(
			name: "Changeset",
			targets: ["Changeset"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "Changeset",
			dependencies: [],
			path: "Sources"
		),
		.testTarget(
			name: "ChangesetTests",
			dependencies: ["Changeset"],
			path: "Tests"
		),
	]
)
