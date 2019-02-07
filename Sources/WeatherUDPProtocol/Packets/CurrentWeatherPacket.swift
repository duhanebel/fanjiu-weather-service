//
//  CurrentWeatherPacket.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 06/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct CurrentWeatherPacket: BinaryCodable {
    struct Padding11 : StaticNibble, BinaryCodable {
        static let length = 11
        let value: PacketDataArray
        
        public init(value: PacketDataArray = PacketDataArray(hex: "FF:FF:FF:FF:FF:FF:FF:FF:FF:FF:FF")) {
            self.value = value
        }
    }

    let unknown1: UInt32
    let unknown2: UInt8
    public let feelsLike: Temperature
    public let pressure: Float
    public let windSpeed: Float
    let unknown3: UInt8
    public let windDirection: UInt8
    let unknown4: CurrentWeatherPacket.Padding11
    let unknown5: UInt16
    
    init(unknown1: UInt32, unknown2: UInt8, feelsLike: Temperature, pressure: Float, windSpeed: Float, unknown3: UInt8, windDirection: UInt8, unknown4: CurrentWeatherPacket.Padding11, unknown5: UInt16) {
        self.unknown1 = unknown1
        self.unknown2 = unknown2
        self.feelsLike = feelsLike
        self.pressure = pressure
        self.windSpeed = windSpeed
        self.unknown3 = unknown3
        self.windDirection = windDirection
        self.unknown4 = unknown4
        self.unknown5 = unknown5
    }
    
    public init(feelsLike: Float, pressure: Float, windSpeed: Float, windDirection: UInt8) {
        let padding = CurrentWeatherPacket.Padding11()
        self.init(unknown1: UInt32(0xFFFFFFFF),
                  unknown2: UInt8(0xFF),
                  feelsLike: Temperature(fahrenheit: feelsLike),
                  pressure: pressure,
                  windSpeed: windSpeed,
                  unknown3: UInt8(0xFF),
                  windDirection: windDirection,
                  unknown4: padding,
                  unknown5: UInt16(0xFFFF))
    }
}

extension CurrentWeatherPacket: Equatable {
    public static func == (lhs: CurrentWeatherPacket, rhs: CurrentWeatherPacket) -> Bool {
        return lhs.feelsLike == rhs.feelsLike &&
        lhs.pressure == rhs.pressure &&
        lhs.windSpeed == rhs.windSpeed &&
        lhs.windDirection == rhs.windDirection
    }
}
