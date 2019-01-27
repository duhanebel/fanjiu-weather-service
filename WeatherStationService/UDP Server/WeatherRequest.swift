//
//  WeatherRequest.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 28/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

enum DeserializationError: Error {
    case invalidPacketFormat
    case invalidChecksum
}

struct ForecastRequestPacket: WeatherStationPacket {
    var commandID: ProtocolCommand
    
    var payload: PacketDataArray
    
    var MACAddress: PacketDataArray
    
    init(data: PacketDataArray) throws {
        let protocolPrefix = ProtocolConstants.header.packetData
        let protocolSuffix = ProtocolConstants.footer.packetData
        guard data.starts(with: protocolPrefix) &&
              Array(data.suffix(protocolSuffix.count)) == protocolSuffix
            else {
                throw DeserializationError.invalidPacketFormat
        }
        
        let MACaddressSize = 6
        let checksumSize = 2

        let payloadSlice = data.dropFirst(protocolPrefix.count).dropLast(protocolSuffix.count)
        
        let checksum = PacketDataArray(payloadSlice.suffix(checksumSize))

        MACAddress = PacketDataArray(payloadSlice.prefix(MACaddressSize))
        
        payload = PacketDataArray(payloadSlice.dropFirst(MACaddressSize).dropLast(checksumSize))
        
        guard payload.sum16CheckSum().uint8Array == checksum else {
            throw DeserializationError.invalidChecksum
        }
        
        guard let command = ProtocolCommand(data: payload) else {
            throw DeserializationError.invalidPacketFormat
        }
        
        self.commandID = command
    }
}
