//
//  Country.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

// Hardcoded UK
public struct Country: BinaryCodable, StaticNibble {
    public static let length = 2
    public let value: PacketDataArray
    public init(value: PacketDataArray) throws {
        let uk = PacketDataArray(hex: "0C:13")
        guard value == uk else {
            throw BinaryDecoder.Error.staticMessageDoesNotMatch(value, value)
        }
        self.value = value
    }
}
