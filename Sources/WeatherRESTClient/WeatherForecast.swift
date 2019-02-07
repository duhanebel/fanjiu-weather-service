//
//  WeatherForecast.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 26/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct WeatherAPIResponse: Decodable {
    public let currently: WeatherNow
    public let forecast: [WeatherForecast]
    
    public enum CodingKeys: String, CodingKey {
        case currently
        case daily
    }
    
    public enum DailyCodingKeys: String, CodingKey {
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        currently = try container.decode(WeatherNow.self, forKey: .currently)
        let dailyContainer = try container.nestedContainer(keyedBy: DailyCodingKeys.self, forKey: .daily)
        forecast = try dailyContainer.decode([WeatherForecast].self, forKey: .data)
        
    }
}

public enum WeatherIcon: String, Decodable {
    case sunnyDay = "clear-day"
    case sunnyNight = "clear-night"
    case cloudy = "cloudy"
    case rain = "rain"
    case snow = "snow"
    case sleey = "sleet"
    case wind = "wind"
    case fog = "fog"
    case partCloudyDay = "partly-cloudy-day"
    case partCloudyNight = "partly-cloudy-night"
}


public struct WeatherForecast: Decodable {
    public let date: Date
    public let icon: WeatherIcon?
    public let temperatureMin: Float
    public let temperatureMax: Float
    public let pressure: Float
    public let windSpeed: Float
    
    enum CodingKeys: String, CodingKey {
        case date = "time"
        case icon
        case temperatureMin = "temperatureLow"
        case temperatureMax = "temperatureHigh"
        case pressure = "windSpeed"
        case windSpeed = "windBearing"
    }
}

public struct WeatherNow: Decodable {
    public let icon: WeatherIcon?
    public let temperature: Float
    public let feelsLike: Float
    public let pressure: Float
    public let windSpeed: Float
    public let windDirection: Int
    
    enum CodingKeys: String, CodingKey {
        case icon = "icon"
        case temperature = "temperature"
        case feelsLike = "apparentTemperature"
        case pressure = "pressure"
        case windSpeed = "windSpeed"
        case windDirection = "windBearing"
    }
}
