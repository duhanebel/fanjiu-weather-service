//
//  NextDaysForecastPacketTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 05/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest

class NextDaysForecastPacketTests: XCTestCase {
    
    var mockForecastPacket: NextDaysForecastPacket!
    let mockForecastData: [UInt8] = [
    0xA1, 0xFF, 0xFF, 0xc4, 0x04, 0x6A, 0x04,
    0xA2, 0xFF, 0xFF, 0xce, 0x04, 0x60, 0x04,
    0xA3, 0xFF, 0xFF, 0xd8, 0x04, 0x56, 0x04,
    0xA4, 0xFF, 0xFF, 0xe2, 0x04, 0x4c, 0x04,
    0xA5, 0xFF, 0xFF, 0xec, 0x04, 0x42, 0x04, ]
    
    override func setUp() {
        mockForecastPacket = NextDaysForecastPacket(
            today: WeatherForecastBin(icon: 0xA1, tempMax: 32.0, tempMin: 23.0),
            day1: WeatherForecastBin(icon: 0xA2, tempMax: 33.0, tempMin: 22.0),
            day2: WeatherForecastBin(icon: 0xA3, tempMax: 34.0, tempMin: 21.0),
            day3: WeatherForecastBin(icon: 0xA4, tempMax: 35.0, tempMin: 20.0),
            day4: WeatherForecastBin(icon: 0xA5, tempMax: 36.0, tempMin: 19.0)
        )
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncoding() {
        let encoded = try! BinaryEncoder.encode(mockForecastPacket)
        XCTAssertEqual(encoded, mockForecastData)
    }
    
    func testDecoding() {
        let decoded = try! BinaryDecoder.decode(NextDaysForecastPacket.self, data: mockForecastData)
        XCTAssertEqual(decoded, mockForecastPacket)
    }

}
