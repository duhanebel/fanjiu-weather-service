//
//  TemperatureTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest

class TemperatureTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTemperatureValues() {
        XCTAssertEqual(try BinaryEncoder.encode(Temperature(fahrenheit: 32)), [0xc4, 0x04])
        
        XCTAssertEqual(try BinaryEncoder.encode(Temperature(fahrenheit: 42)), [0x28, 0x05])
        
        XCTAssertEqual(try BinaryEncoder.encode(Temperature(fahrenheit: 18)), [0x38, 0x04])
    }

    func testTemperatureRoundTrip() {
        AssertRoundtrip(Temperature(fahrenheit: 32))
        AssertRoundtrip(Temperature(fahrenheit: 12))
        AssertRoundtrip(Temperature(fahrenheit: 102))
        AssertRoundtrip(Temperature(celsius: 0))
        AssertRoundtrip(Temperature(celsius: 10))
        AssertRoundtrip(Temperature(celsius: -5))
        //AssertRoundtrip(Temperature(celsius: 1))
    }

}
