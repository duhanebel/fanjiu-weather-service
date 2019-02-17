//
//  Country.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

// Hardcoded UK
private let uk_array = PacketDataArray(hex: "0C:13")

public struct Country: BinaryCodable, StaticNibble {
    public static let length = 2
    public let value: PacketDataArray
    public init(value: PacketDataArray) throws {
        
        guard value == uk_array else {
            throw BinaryDecoder.Error.staticMessageDoesNotMatch(value, uk_array)
        }
        self.value = value
    }
    
    public static var uk: Country {
        return try! self.init(value: uk_array)
    }
}

extension Country : Equatable {}

extension Country: Sizeable {
    public var size: Int { return Country.length }
}
