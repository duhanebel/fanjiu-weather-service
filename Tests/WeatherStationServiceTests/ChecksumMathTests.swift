//
//  ChecksumMathTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest

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
        XCTAssertEqual(sum[0], 0x0C)
        XCTAssertEqual(sum[1], 0x09)
    }
    
    func testCanGenerateSumChecksumWithOddSize() {
        // from 1,2,3,4,5
        // to: 0x102, 0x304, 0x05 [0x00]
        // sum = 0x906 -> [0x06, 0x09] (little endian)
        let source: Array<UInt8> = [0x1,0x2 ,0x3,0x4,0x5]
        let sum = source.sum16CheckSum().uint8Array
        XCTAssertEqual(sum[0], 0x06)
        XCTAssertEqual(sum[1], 0x09)
    }
    
    func testConversionFromUInt16ToArray() {
        let source: Array<UInt8> = [0x49, 0x1]
        let value = UInt16(0x149).uint8Array
        XCTAssertEqual(value, source)
        
    }
}
