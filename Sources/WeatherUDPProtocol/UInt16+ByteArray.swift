//
//  UInt16+ByteArray.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

extension UInt16 {
    public var uint8Array: Array<UInt8> {
        return [UInt8(self & 0x00FF), UInt8(self >> 8)]
    }
}
