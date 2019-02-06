//
//  Test.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 01/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest

struct D : BinaryEncodable {
    let x = 332
}

struct T : BinaryEncodable {
    let a: UInt16 = 43
    let b: UInt8 = 3
    let c: D = D()
}

protocol BinaryEncodable {
    func binaryEncode()
    
}
extension BinaryEncodable {
    func binaryEncode() {
    Mirror(reflecting: self).children.forEach { prop in
        let name = prop.label
        let value = prop.value
        print("\(name) - \(value)")
    }
}
}

class Test: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        T().binaryEncode()
    }

}
