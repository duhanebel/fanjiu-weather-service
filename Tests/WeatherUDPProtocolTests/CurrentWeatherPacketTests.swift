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
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        0x1e, 0x05,
        0xc2, 0x27,
        0x3c, 0x00,
        0xFF,
        0x0b,
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        0xFF, 0xFF]

    override func setUp() {
        mockPacket = CurrentWeatherPacket(feelsLike: 41, pressure: 1017.8, windSpeed: 6, windDirection: 11)
        
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
