//
//  WeatherForecast.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 26/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

struct WeatherAPIResponse: Decodable {
    let currently: WeatherNow
    let forecast: [WeatherForecast]
    
    enum CodingKeys: String, CodingKey {
        case currently
        case daily
    }
    
    enum DailyCodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        currently = try container.decode(WeatherNow.self, forKey: .currently)
        let dailyContainer = try container.nestedContainer(keyedBy: DailyCodingKeys.self, forKey: .daily)
        forecast = try dailyContainer.decode([WeatherForecast].self, forKey: .data)
        
    }
}

enum WeatherIcon: String, Decodable {
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


struct WeatherForecast: Decodable {
    let date: Date
    let icon: WeatherIcon?
    let temperatureMin: Float
    let temperatureMax: Float
    let pressure: Float
    let windSpeed: Float
    
    enum CodingKeys: String, CodingKey {
        case date = "time"
        case icon
        case temperatureMin = "temperatureLow"
        case temperatureMax = "temperatureHigh"
        case pressure = "windSpeed"
        case windSpeed = "windBearing"
    }
}

struct WeatherNow: Decodable {
    let icon: WeatherIcon?
    let temperature: Float
    let feelsLike: Float
    let pressure: Float
    let windSpeed: Float
    let windDirection: Int
    
    enum CodingKeys: String, CodingKey {
        case icon = "icon"
        case temperature = "temperature"
        case feelsLike = "apparentTemperature"
        case pressure = "pressure"
        case windSpeed = "windSpeed"
        case windDirection = "windBearing"
    }
}
