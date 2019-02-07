//
//  FlatRoundingTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 28/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest
import WeatherUDPProtocol

class FlatRoundingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testItRoundsDown() {
        let value: Float = 12.2
        XCTAssertEqual(value.uint16Rounded, UInt16(12))
    }
    func testItRoundsUp() {
        let value: Float = 16.7
        XCTAssertEqual(value.uint16Rounded, UInt16(17))
    }
    func testItRoundsMiddle() {
        let value: Float = 14.5
        XCTAssertEqual(value.uint16Rounded, UInt16(15))
    }

}
