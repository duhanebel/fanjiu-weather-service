//
//  StaticNibble.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public protocol StaticNibble {
    static var length: Int { get }
    var value: PacketDataArray { get }
    init(value: PacketDataArray) throws
}

public extension StaticNibble where Self: BinaryCodable {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        try encoder.encode(value)
    }
    
    public init(fromBinary decoder: BinaryDecoder) throws {
        var value = PacketDataArray()
        for _ in 0..<Self.length {
            value.append(try decoder.decode(UInt8.self))
        }
        try self.init(value: value)
    }
}
