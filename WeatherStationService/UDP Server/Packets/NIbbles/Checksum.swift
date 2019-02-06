//
//  Checksum.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 03/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

struct Checksum {
    fileprivate let value: UInt16
    init(value: UInt16 = 0) {
        self.value = value
    }
}

extension Checksum: BinaryCodable {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        // Data is already organised in little endian so we need to append
        // it big endian style
        encoder.appendBytes(of: encoder.calculateChecksum().bigEndian)
    }
    
    public init(fromBinary decoder: BinaryDecoder) throws {
        value = try decoder.decode(UInt16.self)
    }
}
