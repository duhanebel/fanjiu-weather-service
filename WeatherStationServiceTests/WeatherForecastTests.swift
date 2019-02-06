//
//  WeatherForecastTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest

class WeatherForecastTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncoding() {
        let weather = WeatherForecastBin(icon: 0xA1, tempMax: Temperature(fahrenheit: 42), tempMin: Temperature(fahrenheit: 32))
        AssertRoundtrip(weather)
    }

}
