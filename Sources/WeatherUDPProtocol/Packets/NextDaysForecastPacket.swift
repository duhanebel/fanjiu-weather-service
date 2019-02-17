//
//  WeatherPacket.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct NextDaysForecastPacket: BinaryCodable {
    public let stationID: UInt8
    public let country: Country
    public let date: Date
    public let today: WeatherForecastBin
    public let day1: WeatherForecastBin
    public let day2: WeatherForecastBin
    public let day3: WeatherForecastBin
    public let day4: WeatherForecastBin
    
    public init(stationID: UInt8 = UInt8(1), country: Country, date: Date, today: WeatherForecastBin, day1: WeatherForecastBin, day2: WeatherForecastBin, day3: WeatherForecastBin, day4: WeatherForecastBin) {
        self.stationID = stationID
        self.country = country
        self.date = date
        self.today = today
        self.day1 = day1
        self.day2 = day2
        self.day3 = day3
        self.day4 = day4
    }
}

extension NextDaysForecastPacket: Equatable { }

extension NextDaysForecastPacket: Sizeable {
    public var size: Int {
        return 1 +  // weather station 1 byte
               country.size +
               5 +  // date is 5 bytes
               5 * today.size // there are 5 WeatherForecastBin
    }
}
