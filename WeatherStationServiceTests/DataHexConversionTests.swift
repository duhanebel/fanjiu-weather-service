//
//  UDPForecastPacket.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

@testable import WeatherStationService
import XCTest

class DataHexConversionTests: XCTestCase {
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testArrayFromHexPlain() {
        let hexString = "1122eeFF"
        let array = Array<UInt8>(hex: hexString)
        XCTAssertEqual(array[0], 0x11)
        XCTAssertEqual(array[1], 0x22)
        XCTAssertEqual(array[2], 0xee)
        XCTAssertEqual(array[3], 0xff)
    }
    
    func testArrayFromHexPrefix() {
        let hexString = "0x1122eeFF"
        let array = Array<UInt8>(hex: hexString)
        XCTAssertEqual(array[0], 0x11)
        XCTAssertEqual(array[1], 0x22)
        XCTAssertEqual(array[2], 0xee)
        XCTAssertEqual(array[3], 0xff)
    }
    
    func testArrayFromHexSeparator() {
        let hexString = "11:22:ee:FF"
        let array = Array<UInt8>(hex: hexString)
        XCTAssertEqual(array[0], 0x11)
        XCTAssertEqual(array[1], 0x22)
        XCTAssertEqual(array[2], 0xee)
        XCTAssertEqual(array[3], 0xff)
    }
    
    func testHexFromArray() {
        let hexString = "11:22:ee:ff"
        let array: Array<UInt8> = [ 0x11, 0x22, 0xee, 0xff]
        XCTAssertEqual(hexString, array.hexString)
    }
}


