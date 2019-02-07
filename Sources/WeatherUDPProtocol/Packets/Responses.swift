//
//  Responses.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 06/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct HelloResponse { }

public struct Unknown1Response {}

public struct Unknown2AResponse {}
public struct Unknown2BResponse {}
public struct Unknown2CResponse {}
public struct Unknown3Response {}

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
