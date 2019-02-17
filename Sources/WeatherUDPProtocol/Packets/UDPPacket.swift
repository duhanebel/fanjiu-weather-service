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

public protocol Sizeable {
    var size: Int { get }
}

public struct UDPPacket<T: BinaryCodable & Sizeable>: BinaryCodable {
    public let header: Header
    public let mac: MACAddress
    public let command: Command
    public let payloadSize: UInt16
    public let payload: T
    public let checksum: Checksum
    public let footer: Footer
    
    public init(command: Command, mac: MACAddress, payload: T) {
        // Size is from command onward
        let commandSize = UInt16(payload.size)

        self.header = Header.default
        self.command = command
        self.mac = mac
        self.payloadSize = commandSize
        self.payload = payload
        self.checksum = Checksum()
        self.footer = Footer.default
    }
}

 
