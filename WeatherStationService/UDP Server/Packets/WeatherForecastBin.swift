//
//  WeatherForecast.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation



struct WeatherForecastBin {
    let icon: UInt8
    let unknown: UInt16
    let tempMax: Temperature
    let tempMin: Temperature
    
    init(icon: UInt8, unknown: UInt16 = 0xFFFF, tempMax: Temperature, tempMin: Temperature) {
        self.icon = icon
        self.unknown = unknown
        self.tempMax = tempMax
        self.tempMin = tempMin
    }
    
    init(icon: UInt8, tempMax: Float, tempMin: Float) {
        self.init(icon: icon, tempMax: Temperature(fahrenheit: tempMax),
                  tempMin: Temperature(fahrenheit: tempMin))
    }
}

extension WeatherForecastBin: Equatable {
    static func == (lhs: WeatherForecastBin, rhs: WeatherForecastBin) -> Bool {
        return lhs.icon == rhs.icon && lhs.tempMax == rhs.tempMax && lhs.tempMin == lhs.tempMin
    }
}

extension WeatherForecastBin: BinaryCodable {}
