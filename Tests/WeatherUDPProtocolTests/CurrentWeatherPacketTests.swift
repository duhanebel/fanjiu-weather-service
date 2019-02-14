//
//  CurrentWeatherPacketTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 06/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest
import WeatherUDPProtocol

class CurrentWeatherPacketTests: XCTestCase {

    var mockPacket: CurrentWeatherPacket!
    let mockData: [UInt8] = [
        0x01,                                     // station ID?
        0x0C, 0x13,                               // country - uk
        0x2, 0x5, 0x15, 0x2, 0x34,                // date - 1549400572
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        0x1e, 0x05,
        0xc2, 0x27,
        0x3c, 0x00,
        0xFF,
        0x03, // wind direction - 90 degrees
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        0xFF, 0xFF]

    override func setUp() {
        let date = Date(timeIntervalSince1970: 1549400572)
        mockPacket = CurrentWeatherPacket(country: Country.uk,
                                          date: date,
                                          feelsLike: Float(41),
                                          pressure: Float(1017.8),
                                          windSpeed: Float(6.0),
                                          windDirectionDegrees: 90)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEncoding() throws {
        let encoded = try BinaryEncoder.encode(mockPacket)
        XCTAssertEqual(encoded, mockData)
    }
    
    func testDecoding() throws {
        let decoded = try BinaryDecoder.decode(CurrentWeatherPacket.self, data: mockData)
        XCTAssertEqual(decoded, mockPacket)
    }

}
