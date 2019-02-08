//
//  UDPPacket.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 06/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

private struct UDPPacketHeader: BinaryCodable {
    public let header: Header
    public let mac: MACAddress
    public let command: Command
    public let payloadSize: UInt16
}

public enum UDPPacketUtils {
    public static func inspectDataForCommandID(data: PacketDataArray) throws -> CommandID {
        let header = try BinaryDecoder.decode(UDPPacketHeader.self, data: data)
        return header.command.id
    }
}

public struct UDPPacket<T: BinaryCodable>: BinaryCodable {
    public let header: Header
    public let mac: MACAddress
    public let command: Command
    public let payloadSize: UInt16
    public let stationID: UInt8
    public let country: Country
    public let date: Date
    public let payload: T
    public let checksum: Checksum
    public let footer: Footer
    
    public init(command: Command, mac: MACAddress, country: Country, date:Date, payload: T) {
        // Size is from command onward
        let commandSize = UInt16(
            MemoryLayout<UInt8>.size   +  // station ID is 1
            MemoryLayout<Country>.size +
            5                          +  // Date is MM:DD:hh:mm:ss
            MemoryLayout<T>.size)
        
        self.header = Header.default
        self.command = command
        self.mac = mac
        self.stationID = UInt8(1) // We only support one station
        self.payloadSize = commandSize
        self.country = country
        self.date = date
        self.payload = payload
        self.checksum = Checksum()
        self.footer = Footer.default
    }
}

