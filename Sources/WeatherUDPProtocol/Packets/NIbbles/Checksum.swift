//
//  Checksum.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 03/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct Checksum {
    fileprivate let value: UInt16
    public init(value: UInt16 = 0) {
        self.value = value
    }
}

extension Checksum: BinaryCodable {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        encoder.appendBytes(of: encoder.calculateChecksum())
    }
    
    public init(fromBinary decoder: BinaryDecoder) throws {
        value = try decoder.decode(UInt16.self)
        guard value == decoder.calculateChecksum() else {
            throw BinaryDecoder.Error.invalidChecksum
        }
    }
}
