//
//  Array+Hex.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

extension Array where Element: BinaryInteger, Element.IntegerLiteralType == UInt8 {
    public init(hex: String) {
        self.init()
        
        let hexNoColons = hex.replacingOccurrences(of: ":", with: "")
        let utf8 = Array<Element.IntegerLiteralType>(hexNoColons.utf8)
        let skip0x = hex.hasPrefix("0x") ? 2 : 0
        
        for idx in stride(from: utf8.startIndex.advanced(by: skip0x), to: utf8.endIndex, by: utf8.startIndex.advanced(by: 2)) {
            let byteHex = "\(UnicodeScalar(utf8[idx]))\(UnicodeScalar(utf8[idx.advanced(by: 1)]))"
            if let byte = UInt8(byteHex, radix: 16) {
                self.append(byte as! Element)
            }
        }
    }
    
    public func data() -> Data {
        return Data(buffer: UnsafeBufferPointer(start: self, count: self.count))
    }
    
}
