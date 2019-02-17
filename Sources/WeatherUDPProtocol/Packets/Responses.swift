//
//  Responses.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 06/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct HelloResponse: BinaryCodable, Sizeable {
    public init() {}
    public var size: Int { return 0 }
}

public struct Unknown1Response: BinaryCodable {
    public init() {}
}

public struct Unknown2AResponse: BinaryCodable {
    public let unknown: UInt32
    public init(unknown: UInt32 = 0x9407c404) {
        self.unknown = unknown
    }
}

public struct Unknown2BResponse: BinaryCodable {
    public let unknown: UInt8
    public init(unknown: UInt8 = 0x03) {
        self.unknown = unknown
    }
}

public struct Unknown2CResponse: BinaryCodable {
    public let unknown: UInt16
    public init(unknown: UInt16 = 0x5f14) {
        self.unknown = unknown
    }
}

public struct Unknown3Response: BinaryCodable {
    public let unknown: UInt16
    public init(unknown: UInt16 = 0x4f4b) { // this is "OK" too
        self.unknown = unknown
    }
}

private let OKMessage = PacketDataArray(hex: "4F:4B")
public struct LocalDataOKResponse: BinaryCodable, StaticNibble {
    public static let length = 2
    public let value: PacketDataArray
    
    public init(value: PacketDataArray = PacketDataArray(hex: "aa:3c:57:01")) throws {
        guard value == OKMessage else {
            throw BinaryDecoder.Error.staticMessageDoesNotMatch(value, OKMessage)
        }
        self.value = value
    }
}
