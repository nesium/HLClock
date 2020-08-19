// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "HLClock",
  products: [
    .library(name: "HLClock", targets: ["HLClock"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "HLClock", dependencies: []),
    .testTarget(name: "HLClockTests", dependencies: ["HLClock"]),
  ]
)
