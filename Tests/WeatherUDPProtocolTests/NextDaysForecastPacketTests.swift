//
//  NextDaysForecastPacketTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 05/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest
import WeatherUDPProtocol

class NextDaysForecastPacketTests: XCTestCase {
    
    var mockForecastPacket: NextDaysForecastPacket!
    let mockForecastData: [UInt8] = [
        0x01,                                     // station ID?
        0x0C, 0x13,                               // country - uk
        0x2, 0x5, 0x15, 0x2, 0x34,                // date - 1549400572
        0x00, 0xFF, 0xFF, 0xc4, 0x04, 0x6A, 0x04, // today
        0x01, 0xFF, 0xFF, 0xce, 0x04, 0x60, 0x04, // forecast tomorrow...
        0x06, 0xFF, 0xFF, 0xd8, 0x04, 0x56, 0x04, // etc
        0x08, 0xFF, 0xFF, 0xe2, 0x04, 0x4c, 0x04,
        0x0D, 0xFF, 0xFF, 0xec, 0x04, 0x42, 0x04
        ]
    
    override func setUp() {
        let date = Date(timeIntervalSince1970: 1549400572)
        mockForecastPacket = NextDaysForecastPacket(
            country: Country.uk,
            date: date,
            today: WeatherForecastBin(icon: .sunny, tempMax: 32.0, tempMin: 23.0),
            day1: WeatherForecastBin(icon: .mostSunny, tempMax: 33.0, tempMin: 22.0),
            day2: WeatherForecastBin(icon: .partiallyCloudy, tempMax: 34.0, tempMin: 21.0),
            day3: WeatherForecastBin(icon: .mostlyCloudy, tempMax: 35.0, tempMin: 20.0),
            day4: WeatherForecastBin(icon: .heavyRain, tempMax: 36.0, tempMin: 19.0)
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
