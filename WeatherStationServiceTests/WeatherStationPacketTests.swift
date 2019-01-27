//
//  WeatherStationPacketTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest

struct MockPacket: WeatherStationPacket {
    var commandID = ProtocolCommand.resForecast
    
    var payload: PacketDataArray = PacketDataArray(hex: "ee:ff:ee")

    var MACAddress = PacketDataArray(hex: "00:95:69")
}

class WeatherStationPacketTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSamplePacketCreation() {
        let data = MockPacket().packetData
        let dataCheck = PacketDataArray(hex: "aa:3c:57:01:00:95:69:52:31:00:00:2b:00:01:ee:ff:ee:4f:79:cc:3e")
        XCTAssertEqual(data, dataCheck)
    }
    
    func testInitializeCommandFromArray() {
        let command = ProtocolCommand(data: PacketDataArray(hex:
            "52:30:01:00:00:00"))
        XCTAssertNotNil(command)
        XCTAssertEqual(command, ProtocolCommand.reqCurrentWeather)
    }
}
