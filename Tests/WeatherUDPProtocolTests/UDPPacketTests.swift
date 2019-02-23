//
//  UDPPacketTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 05/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest
import WeatherUDPProtocol

class UDPPacketTests: XCTestCase {
    
    struct MockPayload: BinaryCodable {
        let value: UInt8
    }
    
   // var mockPacket: UDPPacket<MockPayload>!
    
    var mockPacketRawData: [UInt8] = [
        0xaa, 0x3c, 0x57, 0x01,             // header
        0xAA, 0x11, 0x22, 0x33, 0x44, 0xEE, // MAC
        0x52, 0x31, 0x00, 0x00,             // command
        0x2b, 0x00,                         // packet size (from now on)
        0x33,                               // payload
        0xE6, 0xED,                         // checksum
        0xcc, 0x3e                          // footer
    ]
    
    override func setUp() {
        let cmd = Command(commandID: .responseForecast)
        let mac = MACAddress(address: PacketDataArray(hex: "AA:11:22:33:44:EE"))
        let payload = MockPayload(value: 0x33)
        
    //    mockPacket = UDPPacket(command:cmd, mac:mac, payload:payload)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncodingSamplePacket() throws {
        let encodedData = try BinaryEncoder.encode(mockPacketRawData)
        XCTAssertEqual(encodedData, mockPacketRawData)
    }

//    func testDecodingSamplePacket() throws {
//        let packet = try BinaryDecoder.decode(UDPPacket<MockPayload>.self, data: mockPacketRawData)
//
//        XCTAssertEqual(packet.command.value, mockPacket.command.value)
//        XCTAssertEqual(packet.mac.address, mockPacket.mac.address)
//        XCTAssertEqual(packet.payload.value, mockPacket.payload.value)
//
//    }
    
    func testHeaderDecoding() throws {
        let commandID = try UDPPacketUtils.inspectDataForCommandID(data: mockPacketRawData)
        XCTAssertEqual(commandID, .responseForecast)
    }
}
