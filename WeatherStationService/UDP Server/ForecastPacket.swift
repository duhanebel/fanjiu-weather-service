//
//  UDPForecastPacket.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

typealias PacketDataArray = Array<UInt8>

enum ProtocolConstants: String, PacketDataRappresentable {
    case header = "aa:3c:57:01"
    case footer = "cc:3e"
}

 enum ProtocolCommand: String, PacketDataRappresentable {
    case resForecast       = "52:31:00:00:2b:00:01"
    case resCurrentWeather = "52:30:00:00:22:00:01"
    case resHello1         = "01:01:01:01:00:00"
    case resHello2         = "02:02:00:01:00:00"
    case resMultiReq       = "FF:FF"
    case resLocalData      = "53:30:00:00:02:00:4f:4b"
    
    case reqHello1         = "01:01:01:00:00:00"
    case reqHello2         = "02:02:01:00:00:00"
    case reqMultiReq       = "57:00:01:00:00:00"
    case reqForecast       = "52:31:01:00:00:00"
    case reqCurrentWeather = "52:30:01:00:00:00"
    case reqLocalData      = "53:30:01:00:32:00:01"
}

extension ProtocolCommand {
    init?(data: PacketDataArray) {
        
        let str = data.reduce("") { acc, val in
            return acc + String(format:"%02X:", val)
        }
        
        self.init(rawValue: String(str.dropLast()))
    }
}

protocol PacketDataRappresentable {
    var packetData: PacketDataArray { get }
}

extension PacketDataRappresentable where Self: RawRepresentable, Self.RawValue == String {
    var packetData: PacketDataArray {
        return PacketDataArray(hex: self.rawValue)
    }
}

protocol WeatherStationPacket: PacketDataRappresentable {
    var commandID: ProtocolCommand { get }
    var payload: PacketDataArray { get }
    var MACAddress: PacketDataArray { get }
}

extension WeatherStationPacket {
    var packetData: PacketDataArray {
        let openPacket = ProtocolConstants.header.packetData + MACAddress + commandID.packetData + payload
        let checksum = openPacket.sum16CheckSum()
        return openPacket + checksum.uint8Array + ProtocolConstants.footer.packetData
    }
}

struct WeatherForecastData: PacketDataRappresentable {
    let icon: UInt8
    let tempMin: Float
    let tempMax: Float
    
    private let padding = PacketDataArray(hex: "FF:FF")
    var packetData: PacketDataArray {
        
        let utempMin = WeatherTemperature(celsius: tempMin).packetData
        let utempMax = WeatherTemperature(celsius: tempMax).packetData
        return [icon] + padding + utempMax + utempMin
    }
}

enum WeatherCountry: String, PacketDataRappresentable {
    case uk = "0c:13"
}

struct WeatherTemperature: PacketDataRappresentable {
    let temp: Float
    
    init(celsius: Float) {
        temp = 32 + celsius * 9/5
    }
    
    init(farenheit: Float) {
        temp = farenheit
    }
    
    var packetData: PacketDataArray {
        let weatherTemp = 900 + (temp.uint16Rounded * 10)
        return weatherTemp.uint8Array
    }
}

struct WeatherWindPressure: PacketDataRappresentable {
    let value: Int
    var packetData: PacketDataArray {
        return UInt16(value * 10).uint8Array
    }
}

struct WindDirection: PacketDataRappresentable {
    let positionCount = 16
    let degrees: Int
    var packetData: PacketDataArray {
        var index = UInt8((Float(degrees)/360 * Float(positionCount)).rounded())
        index = index % 16
        return [index]
    }
}

struct WeatherDate: PacketDataRappresentable {
    let date: Date
    
    var packetData: PacketDataArray {
        let calendar = Calendar.current
       
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        return [UInt8(month), UInt8(day), UInt8(hour), UInt8(minutes), UInt8(seconds)]
    }
}

struct ForecastPacket: WeatherStationPacket {
    let date: WeatherDate
    let commandID = ProtocolCommand.resForecast
    let country = WeatherCountry.uk
    
    var today: WeatherForecastData
    
    var next4Days: [WeatherForecastData] = []
    
    var payload: PacketDataArray {
        return country.packetData +
               date.packetData +
               today.packetData +
            next4Days.reduce(PacketDataArray(), { $0 + $1.packetData })
    }
    
    var MACAddress: PacketDataArray
}

struct CurrentWeatherPacket: WeatherStationPacket {
    let date: WeatherDate
    let commandID = ProtocolCommand.resCurrentWeather
    let country = WeatherCountry.uk

    private let packetFooter = PacketDataArray(hex: "ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff")
    let packetHeader = PacketDataArray(hex: "FF:FF:FF:FF:FF")
    
    var payload: PacketDataArray {
        var currentConditions = packetHeader
        currentConditions += WeatherTemperature(celsius: feelsLike).packetData
        currentConditions += WeatherWindPressure(value: pressure).packetData
        currentConditions += WeatherWindPressure(value: windSpeed).packetData
        currentConditions += PacketDataArray(hex: "FF")
        currentConditions += [UInt8(windDirection)]
        return country.packetData +
               date.packetData +
               currentConditions +
               packetFooter
    }
    
    var MACAddress: PacketDataArray
    
    let feelsLike: Float
    let pressure: Int
    let windSpeed: Int
    let windDirection: Int
}
