//
//  File.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 02/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

extension Date: BinaryCodable {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        let calendar = Calendar.current
        
        UInt8(calendar.component(.month, from: self)).binaryEncode(to: encoder)
        UInt8(calendar.component(.day, from: self)).binaryEncode(to: encoder)
        UInt8(calendar.component(.hour, from: self)).binaryEncode(to: encoder)
        UInt8(calendar.component(.minute, from: self)).binaryEncode(to: encoder)
        UInt8(calendar.component(.second, from: self)).binaryEncode(to: encoder)
    }
    
    public init(fromBinary decoder: BinaryDecoder) throws {
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.year], from: Date())

        components.month = try Int(decoder.decode(UInt8.self))
        components.day = try Int(decoder.decode(UInt8.self))
        components.hour = try Int(decoder.decode(UInt8.self))
        components.minute = try Int(decoder.decode(UInt8.self))
        components.second = try Int(decoder.decode(UInt8.self))
        
        guard let date = calendar.date(from: components) else {
            throw BinaryDecoder.Error.invalidDate([])
        }
        self = date
    }
}
