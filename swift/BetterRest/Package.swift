// swift-tools-version: 6.0
import PackageDescription

let packageName = "BetterRest"
let package = Package(
  name: "",
  platforms: [.iOS(.v18), .macOS(.v15)],
  products: [
    .library(name: packageName, targets: [packageName])
  ],
  targets: [
    .target(
      name: packageName,
      path: packageName
    )
  ]
)