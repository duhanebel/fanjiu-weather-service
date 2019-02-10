//
//  Country.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

// Hardcoded UK
private let uk = PacketDataArray(hex: "0C:13")

public struct Country: BinaryCodable, StaticNibble {
    public static let length = 2
    public let value: PacketDataArray
    public init(value: PacketDataArray) throws {
        
        guard value == uk else {
            throw BinaryDecoder.Error.staticMessageDoesNotMatch(value, uk)
        }
        self.value = value
    }
    
    public static var uk: Country {
        return try! self.init(value: uk)
    }
}

extension Country : Equatable {}
