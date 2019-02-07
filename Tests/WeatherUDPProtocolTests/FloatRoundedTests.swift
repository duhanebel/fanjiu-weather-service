//
//  FloatRoundedTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest
import WeatherUDPProtocol

class FloatRoundedTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRoundedFloat() {
        XCTAssertEqual(Float(2).rounded(toPlaces: 1), Float(2))
        XCTAssertEqual(Float(2.3).rounded(toPlaces: 1), Float(2.3))
        XCTAssertEqual(Float(2.32).rounded(toPlaces: 1), Float(2.3))
        XCTAssertEqual(Float(9/5 + 32).rounded(toPlaces: 1), Float(33))
        XCTAssertEqual(Float(33.79999923706055).rounded(toPlaces: 1), Float(33.8))
        
    }
    
    func testRoundedDouble() {
        XCTAssertEqual(Double(2).rounded(toPlaces: 1), Double(2))
        XCTAssertEqual(Double(2.3).rounded(toPlaces: 1), Double(2.3))
        XCTAssertEqual(Double(2.32).rounded(toPlaces: 1), Double(2.3))
    }

}
