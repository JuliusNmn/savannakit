// swift-tools-version:5.5
//swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "SavannaKit",
    platforms: [
        .iOS(.v13)],
    products: [
        .library(name: "SavannaKit", type: nil, targets: ["SavannaKit"])],
    targets: [
        .target(name: "SavannaKit")
    ]
    
)
