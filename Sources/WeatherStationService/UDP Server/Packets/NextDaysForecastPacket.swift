//
//  WeatherPacket.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

struct NextDaysForecastPacket: BinaryCodable {
    let today: WeatherForecastBin
    let day1: WeatherForecastBin
    let day2: WeatherForecastBin
    let day3: WeatherForecastBin
    let day4: WeatherForecastBin
}

extension NextDaysForecastPacket: Equatable {

}
