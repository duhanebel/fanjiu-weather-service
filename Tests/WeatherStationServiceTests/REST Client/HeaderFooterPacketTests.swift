//
//  HeaderFooterPacketTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest
import WeatherStationService

class HeaderFooterPacketTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHeaderIsDecodedCorrectly() {
        let data: [UInt8] = [ 0xaa, 0x3c, 0x57, 0x01]
        XCTAssertNoThrow(try BinaryDecoder.decode(Header.self, data: data))
    }
    
    func testFailureWhenDecodingWrongHeader() {
        let badData: [UInt8] = [ 0xFF, 0xFF, 0xFF, 0xFF]
        XCTAssertThrowsError(try BinaryDecoder.decode(Header.self, data: badData))
    }
    
    func testHeaderEncodes() {
        let header = Header.default
        let data: [UInt8] = [ 0xaa, 0x3c, 0x57, 0x01]
        XCTAssertEqual(data, try BinaryEncoder.encode(header))
    }
    
    func testFooterIsDecodedCorrectly() {
        let data: [UInt8] = [ 0xcc, 0x3e]
        XCTAssertNoThrow(try BinaryDecoder.decode(Footer.self, data: data))
    }
    
    func testFailureWhenDecodingWrongFooter() {
        let badData: [UInt8] = [ 0xFF, 0xFF ]
        XCTAssertThrowsError(try BinaryDecoder.decode(Footer.self, data: badData))
    }
    
    func testFooterEncodes() {
        let footer = Footer.default
        let data: [UInt8] = [ 0xcc, 0x3e]
        XCTAssertEqual(data, try BinaryEncoder.encode(footer))
    }
    
}
