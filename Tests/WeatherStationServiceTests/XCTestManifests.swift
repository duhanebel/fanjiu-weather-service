import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WeatherStationServiceTests.allTests),
    ]
}
#endif