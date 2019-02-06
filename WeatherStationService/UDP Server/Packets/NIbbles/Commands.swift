//
//  Command.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

enum CommandID: String {
    case responseForecast       = "52:31:00:00" // size: :2b:00"
    case responseCurrentWeather = "52:30:00:00" // Size: :22:00 stationID :01"
}

struct ResponseCommand: BinaryCodable, StaticNibble {
    static var length = 6
    let value: PacketDataArray
    
    init(commandID: CommandID) {
        self.value = PacketDataArray(hex: commandID.rawValue)
    }
    
    init(value: PacketDataArray) {
        self.value = value
    }
}
