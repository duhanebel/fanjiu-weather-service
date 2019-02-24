//
//  ChecksumMathTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest
import WeatherUDPProtocol

class ChecksumMathTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCanGenerateSumChecksum() {
        // from 1,2,3,4,5,6
        // to: 0x102, 0x304, 0x506
        // sum = 0x90C -> [0x0C, 0x09] (little endian)
        let source: Array<UInt8> = [0x1,0x2 ,0x3,0x4,0x5,0x6]
        let sum = source.sum16CheckSum().uint8Array
        XCTAssertEqual(sum[0], 0x15)
        XCTAssertEqual(sum[1], 0x00)
    }
    
    func testRealLifeChecksum() {
        let source = Array<UInt8>(hex: "AA:3C:57:01:00:95:69:F0:51:80:52:31:00:00:2B:00:01:0C:13:02:17:0A:2E:36:00:FF:FF:D2:05:14:05:00:FF:FF:A0:05:D8:04:00:FF:FF:D2:05:92:04:00:FF:FF:F0:05:A6:04:00:FF:FF:E6:05:A6:04")
        let sum = source.sum16CheckSum().uint8Array
        XCTAssertEqual(sum[0], 0x5A)
        XCTAssertEqual(sum[1], 0x16)
    }
    
    func testRealLifeChecksum2() {
        let source = Array<UInt8>(hex: "AA3C5701009569F05180523100002B00010C130217101E1800FFFFC805140500FFFFA005D80400FFFFD205920400FFFFF005A60400FFFFE605A604")
        let sum = source.sum16CheckSum().uint8Array
        XCTAssertEqual(sum[0], 0x28)
        XCTAssertEqual(sum[1], 0x16)
    }
    
    func testCanGenerateSumChecksumWithOddSize() {
        // from 1,2,3,4,5
        // to: 0x102, 0x304, 0x05 [0x00]
        // sum = 0x906 -> [0x06, 0x09] (little endian)
        let source: Array<UInt8> = [0x1,0x2 ,0x3,0x4,0x5]
        let sum = source.sum16CheckSum().uint8Array
        XCTAssertEqual(sum[0], 0x0F)
        XCTAssertEqual(sum[1], 0x00)
    }
    
    func testConversionFromUInt16ToArray() {
        let source: Array<UInt8> = [0x49, 0x1]
        let value = UInt16(0x149).uint8Array
        XCTAssertEqual(value, source)
        
    }
}
