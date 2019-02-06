//
//  UDPPacketTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 05/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest

class UDPPacketTests: XCTestCase {
    
    struct MockPayload: BinaryCodable {
        let value: UInt8
    }
    
    var mockPacket: UDPPacket<MockPayload>!
    
    var mockPacketRawData: [UInt8] = [
        0xaa, 0x3c, 0x57, 0x01,
        0x52, 0x31, 0x00, 0x00, 0x2b, 0x00,
        0xAA, 0x11, 0x22, 0x33, 0x44, 0xEE,
        0x0C, 0x13,
        0x2, 0x5, 0x15, 0x2, 0x34,
        0x33,
        0xE6, 0xED,
        0xcc, 0x3e
    ]
    
    override func setUp() {
        let cmd = ResponseCommand(commandID: .responseForecast)
        let mac = MACAddress(address: PacketDataArray(hex: "AA:11:22:33:44:EE"))
        let uk = try! Country(value: PacketDataArray(hex: "0C:13"))
        let date = Date(timeIntervalSince1970: 1549400572)
        
        let payload = MockPayload(value: 0x33)
        
        mockPacket = UDPPacket(command:cmd, mac:mac, country:uk, date:date, payload:payload)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncodingSamplePacket() {
        let encodedData = try! BinaryEncoder.encode(mockPacketRawData)
        XCTAssertEqual(encodedData, mockPacketRawData)
    }

    func testDecodingSamplePacket() {
        let packet = try! BinaryDecoder.decode(UDPPacket<MockPayload>.self, data: mockPacketRawData)
        
        XCTAssertEqual(packet.command.value, mockPacket.command.value)
        XCTAssertEqual(packet.mac.address, mockPacket.mac.address)
        XCTAssertEqual(packet.country.value, mockPacket.country.value)
        XCTAssertEqual(packet.date, mockPacket.date)
        XCTAssertEqual(packet.payload.value, mockPacket.payload.value)

    }
}
