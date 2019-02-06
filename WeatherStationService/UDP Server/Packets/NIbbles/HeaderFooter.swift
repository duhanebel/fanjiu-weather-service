//
//  HeaderFooter.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 03/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

private let defaultHeader = PacketDataArray(hex: "aa:3c:57:01")
private let defaultFooter = PacketDataArray(hex: "cc:3e")

struct Header: BinaryCodable, StaticNibble {
    static let length = 4
    var value: PacketDataArray

    init(value: PacketDataArray = PacketDataArray(hex: "aa:3c:57:01")) throws {
        guard value == defaultHeader else {
            throw BinaryDecoder.Error.staticMessageDoesNotMatch(value, value)
        }
        self.value = value
    }
    
    static var `default`: Header {
        return try! Header.init()
    }
}

struct Footer: BinaryCodable, StaticNibble {
    static let length = 2
    var value: PacketDataArray

    init(value: PacketDataArray = PacketDataArray(hex: "cc:3e")) throws {
        guard value == defaultFooter else {
            throw BinaryDecoder.Error.staticMessageDoesNotMatch(value, value)
        }
        self.value = value
    }
    
    static var `default`: Footer {
        return try! Footer.init()
    }
}
