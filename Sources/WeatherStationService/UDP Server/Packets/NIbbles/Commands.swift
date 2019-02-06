//
//  Command.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

enum CommandID: String {
    case responseHello          = "01:01:01:01"
    case responseUnknown1       = "02:02:00:01"
    case responseUnknown2a      = "50:32:00:01"
    case responseUnknown2b      = "43:32:00:01"
    case responseUnknown2c      = "50:33:00:01"
    case responseUnknown3       = "51:32:00:00"
    case responseForecast       = "52:31:00:00" // size: :2b:00"
    case responseCurrentWeather = "52:30:00:00" // Size: :22:00 stationID :01"
    case responseLocalData      = "53:30:00:00"
    
    case requestHello           = "01:01:01:00"
    case requestUnknown1        = "02:02:01:00"
    case requestUnknown2        = "57:00:01:00"
    case requestUnknown3        = "51:32:01:00"
    case requestForecast        = "52:31:01:00"
    case requestCurrentWeather  = "52:30:01:00"
    case requestLocalData       = "53:30:01:00"
    
    var arrayData: PacketDataArray {
        return PacketDataArray(hex: self.rawValue)
    }
    
    init?(arrayData: PacketDataArray) {
        self.init(rawValue: arrayData.hexString)
    }
}

struct Command: BinaryCodable, StaticNibble {
    static var length = 4
    let value: PacketDataArray
    
    init(commandID: CommandID) {
        self.value = commandID.arrayData
    }
    
    init(value: PacketDataArray) throws {
        self.value = value
        guard let _ = CommandID(arrayData: value) else {
            throw BinaryDecoder.Error.invalidProtocolCommand(value)
        }
    }
}
