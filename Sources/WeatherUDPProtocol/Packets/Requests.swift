//
//  Requests.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 06/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct HelloRequest: BinaryCodable {
    public init() {}
}

public struct Unknown1Request: BinaryCodable {
    public init() {}
}

public struct Unknown2Request: BinaryCodable {
    public init() {}
}

public struct Unknown3Request: BinaryCodable {
    let unknown: UInt8
    public init(unknown: UInt8) {
        self.unknown = unknown
    }
}

public struct ForecastRequest: BinaryCodable {
    public init() {}
}

public struct CurrentWeatherRequest: BinaryCodable {
    public init() {}
}

public struct LocalDataRequest: BinaryCodable {
    let unknown1: UInt16
    let unknown2: UInt16
    let unknown3: UInt16
    let unknown4: UInt16
    let unknown5: UInt16
    let unknown6: UInt16
    let unknown7: UInt16
    let unknown8: UInt16
    let unknown9: UInt16
    let unknown10: UInt16
    let unknown11: UInt16
    let unknown12: UInt16
    let unknown13: UInt16
    let unknown14: UInt16
    let unknown15: UInt16
    let unknown16: UInt16
    let unknown17: UInt16
    let unknown18: UInt16
    let unknown19: UInt16
    let unknown20: UInt16
    let unknown21: UInt16

    public init(unknown1: UInt16, unknown2: UInt16, unknown3: UInt16, unknown4: UInt16, unknown5: UInt16, unknown6: UInt16, unknown7: UInt16, unknown8: UInt16, unknown9: UInt16, unknown10: UInt16, unknown11: UInt16, unknown12: UInt16, unknown13: UInt16, unknown14: UInt16, unknown15: UInt16, unknown16: UInt16, unknown17: UInt16, unknown18: UInt16, unknown19: UInt16, unknown20: UInt16, unknown21: UInt16) {
        self.unknown1 = unknown1
        self.unknown2 = unknown2
        self.unknown3 = unknown3
        self.unknown4 = unknown4
        self.unknown5 = unknown5
        self.unknown6 = unknown6
        self.unknown7 = unknown7
        self.unknown8 = unknown8
        self.unknown9 = unknown9
        self.unknown10 = unknown10
        self.unknown11 = unknown11
        self.unknown12 = unknown12
        self.unknown13 = unknown13
        self.unknown14 = unknown14
        self.unknown15 = unknown15
        self.unknown16 = unknown16
        self.unknown17 = unknown17
        self.unknown18 = unknown18
        self.unknown19 = unknown19
        self.unknown20 = unknown20
        self.unknown21 = unknown21
    }
}
