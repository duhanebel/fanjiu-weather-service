//
//  Responses.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 06/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

struct HelloResponse { }

struct Unknown1Response {}

struct Unknown2AResponse {}
struct Unknown2BResponse {}
struct Unknown2CResponse {}
struct Unknown3Response {}

private let OKMessage = PacketDataArray(hex: "4F:4B")
struct LocalDataOKResponse: BinaryCodable, StaticNibble {
    static let length = 2
    let value: PacketDataArray
    
    init(value: PacketDataArray = PacketDataArray(hex: "aa:3c:57:01")) throws {
        guard value == OKMessage else {
            throw BinaryDecoder.Error.staticMessageDoesNotMatch(value, OKMessage)
        }
        self.value = value
    }
}
