//
//  Command.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 04/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public enum CommandID: String {
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

extension CommandID: CustomStringConvertible {
    public var description: String {
        switch(self) {
        case .responseHello:
            return "RES(Hello)"
        case .responseUnknown1:
            return "RES(Unknown1)"
        case .responseUnknown2a:
            return "RES(Unknown2a)"
        case .responseUnknown2b:
            return "RES(Unknown2b)"
        case .responseUnknown2c:
            return "RES(Unknown2c)"
        case .responseUnknown3:
            return "RES(Unknown3)"
        case .responseForecast:
            return "RES(Forecast)"
        case .responseCurrentWeather:
            return "RES(CurrentWeather)"
        case .responseLocalData:
            return "RES(LocalData)"
        case .requestHello:
            return "REQ(Hello)"
        case .requestUnknown1:
            return "REQ(Unknown1)"
        case .requestUnknown2:
            return "REQ(Unknown2)"
        case .requestUnknown3:
            return "REQ(Unknown3)"
        case .requestForecast:
            return "REQ(Forecast)"
        case .requestCurrentWeather:
            return "REQ(CurrentWeather)"
        case .requestLocalData:
            return "REQ(LocalData)"
        }
    }

}

public extension CommandID {
    public func responseFor(request: CommandID) -> CommandID? {
        switch(request) {
        case .requestHello:
            return .responseHello
        case .requestUnknown1:
            return .responseUnknown1
        case .requestUnknown3:
            return .responseUnknown3
        case .requestForecast:
            return .responseForecast
        case .requestCurrentWeather:
            return .responseCurrentWeather
        case .requestLocalData:
            return .responseLocalData
        default:
            return nil
        }
    }
}

public struct Command: BinaryCodable, StaticNibble {
    public static var length = 4
    public let value: PacketDataArray
    
    public init(commandID: CommandID) {
        self.value = commandID.arrayData
    }
    
    public var id: CommandID! {
        return CommandID(arrayData: value)
    }
    
    public init(value: PacketDataArray) throws {
        self.value = value
        guard let _ = CommandID(arrayData: value) else {
            throw BinaryDecoder.Error.invalidProtocolCommand(value)
        }
    }
}
