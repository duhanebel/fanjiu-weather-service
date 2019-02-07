//
//  WeatherForecastTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest
import WeatherUDPProtocol

class WeatherForecastTests: XCTestCase {

    var mockPacket: WeatherForecastBin!
    let mockData: [UInt8] = [
        0xA1, 0xFF, 0xFF, 0x28, 0x05, 0xc4, 0x04
    ]
    override func setUp() {
        mockPacket = WeatherForecastBin(icon: 0xA1, tempMax: 42, tempMin: 32)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRoundTrip() {
        let weather = WeatherForecastBin(icon: 0xA1, tempMax: 42, tempMin: 32)
        AssertRoundtrip(weather)
    }
    
    func testEncoding() throws {
        let encoded = try BinaryEncoder.encode(mockPacket)
        XCTAssertEqual(encoded, mockData)
    }
    
    func testDecoding() throws {
        let decoded = try BinaryDecoder.decode(WeatherForecastBin.self, data: mockData)
        XCTAssertEqual(decoded, mockPacket)
    }

}
