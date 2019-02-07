//
//  Requests.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 06/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct HelloRequest: BinaryCodable {
}


public struct Unknown1Request: BinaryCodable {
}

public struct Unknown2Request: BinaryCodable {
}

public struct Unknown3Request: BinaryCodable {
    let unknown: UInt8
}

public struct ForecastRequest: BinaryCodable {
}

public struct CurrentWeatherRequest: BinaryCodable {
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
}
