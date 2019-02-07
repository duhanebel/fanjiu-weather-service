//
//  ArrayUInt8+BinaryCodable.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

extension Array: BinaryEncodable where Element == UInt8 {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        try self.forEach { try $0.encode(to: encoder) }
    }
}
