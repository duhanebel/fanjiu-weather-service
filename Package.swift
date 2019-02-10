// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherStationService",
    products: [
      .executable(name: "WeatherStationService", targets: ["WeatherStationService"]),
      .library(name: "WeatherUDPProtocol", targets: ["WeatherUDPProtocol"]),
      .library(name: "WeatherRESTClient", targets: ["WeatherRESTClient"])],
    dependencies: [ ],
    targets: [
        .target(
            name: "WeatherStationService",
            dependencies: ["WeatherUDPProtocol", "WeatherRESTClient"]),
        .target(
            name: "WeatherUDPProtocol",
            dependencies: []),
        .target(
            name: "WeatherRESTClient",
            dependencies: []),
        .testTarget(
            name: "WeatherUDPProtocolTests",
            dependencies: ["WeatherUDPProtocol"]),
        .testTarget(
            name: "WeatherRESTClientTests",
            dependencies: ["WeatherRESTClient"])
    ]
)
