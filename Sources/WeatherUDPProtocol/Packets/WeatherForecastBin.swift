//
//  WeatherForecast.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation



public struct WeatherForecastBin {
    public enum Icon: UInt8, BinaryCodable {
        case sunny            = 0x00 // verified
        case mostSunny        = 0x01 // verified
        case partiallyCloudy  = 0x06 // verified
        case mostlyCloudy     = 0x08 // verified
        case cloudy           = 0x09
        case patchyRain       = 0x0A
        case mostlyRain       = 0x0B
        case showers          = 0x0C
        case heavyRain        = 0x0D // verified
        case thunderRain      = 0x10 // verified
        case rainAndHail      = 0x11
        case hail             = 0x12
        case snowAndHail      = 0x13
        case patchySnow       = 0x14
        case mostlySnow       = 0x15
        case snowShower       = 0x16
        case heavySnow        = 0x17
        case rainAndSnow      = 0x18
        case foggy            = 0x19
        case windy            = 0x1A
    }
    
    public let icon: Icon
    public let unknown: UInt16
    public let tempMax: Temperature
    public let tempMin: Temperature
    
    public init(icon: Icon, unknown: UInt16 = 0xFFFF, tempMax: Temperature, tempMin: Temperature) {
        self.icon = icon
        self.unknown = unknown
        self.tempMax = tempMax
        self.tempMin = tempMin
    }
    
    public init(icon: Icon, tempMax: Float, tempMin: Float) {
        self.init(icon: icon, tempMax: Temperature(fahrenheit: tempMax),
                  tempMin: Temperature(fahrenheit: tempMin))
    }
}

extension WeatherForecastBin: Sizeable {
    public var size: Int { return 1 + 2 + 2 + 2 }
}

extension WeatherForecastBin: Equatable {
    public static func == (lhs: WeatherForecastBin, rhs: WeatherForecastBin) -> Bool {
        return lhs.icon == rhs.icon && lhs.tempMax == rhs.tempMax && lhs.tempMin == lhs.tempMin
    }
}

extension WeatherForecastBin: BinaryCodable {}
