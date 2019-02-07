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

public struct Header: BinaryCodable, StaticNibble {
    public static let length = 4
    public var value: PacketDataArray

    public init(value: PacketDataArray = PacketDataArray(hex: "aa:3c:57:01")) throws {
        guard value == defaultHeader else {
            throw BinaryDecoder.Error.staticMessageDoesNotMatch(value, defaultHeader)
        }
        self.value = value
    }
    
    public static var `default`: Header {
        return try! Header.init()
    }
}

public struct Footer: BinaryCodable, StaticNibble {
    public static let length = 2
    public var value: PacketDataArray

    public init(value: PacketDataArray = PacketDataArray(hex: "cc:3e")) throws {
        guard value == defaultFooter else {
            throw BinaryDecoder.Error.staticMessageDoesNotMatch(value, defaultFooter)
        }
        self.value = value
    }
    
    public static var `default`: Footer {
        return try! Footer.init()
    }
}
