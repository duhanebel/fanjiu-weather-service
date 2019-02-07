//
//  MacAddress.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 05/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct MACAddress {
    public static let addressLength: Int = 6
    public let address: PacketDataArray
    public init(address: PacketDataArray) {
        self.address = address
    }
}

extension MACAddress: BinaryCodable {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        try encoder.encode(address)
    }
    
    public init(fromBinary decoder: BinaryDecoder) throws {
        var value = PacketDataArray()
        for _ in 0..<MACAddress.addressLength {
            value.append(try decoder.decode(UInt8.self))
        }
        self.init(address: value)
    }
}
