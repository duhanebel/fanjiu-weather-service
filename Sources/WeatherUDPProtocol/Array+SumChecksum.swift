//
//  Array+SumChecksum.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

extension Array where Element: BinaryInteger, Element.IntegerLiteralType == UInt8 {
    public func sum16CheckSum() -> UInt16 {
        let checksum = stride(from: 0, to: self.endIndex, by: 2).reduce(0) { acc, index in
            let higher = UInt16(self[index])
            let lower = (index.advanced(by:1) < self.count) ? UInt16(self[index.advanced(by:1)]): 0
            let value = Int((higher << 8 | lower))
            return acc + value
        }
    
        return UInt16(checksum & 0xFFFF)
    }
}


