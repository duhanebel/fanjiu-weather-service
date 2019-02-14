//
//  ForecastRequestProcessor.swift
//  WeatherRESTClient
//
//  Created by Fabio Gallonetto on 14/02/2019.
//

import Foundation
import WeatherUDPProtocol
import WeatherRESTClient

private extension WeatherForecastBin.Icon {
    init(_ weatherIcon: WeatherIcon) {
        switch(weatherIcon) {
        case .sunnyDay:
            fallthrough
        case .sunnyNight:
            self = .sunny
        case .cloudy:
            self = .cloudy
        case .rain:
            self = .heavyRain
        case .snow:
            self = .heavySnow
        case .sleey:
            self = .rainAndSnow
        case .wind:
            self = .windy
        case .fog:
            self = .foggy
        case .partCloudyDay:
            fallthrough
        case .partCloudyNight:
            self = .partiallyCloudy
        }
    }
}

struct ForecastUDPRequestProcessor: WeatherUDPRequestProcessor {
    static var commands = [CommandID.requestForecast]
    
    var weatherService: WeatherClient
    
    init(weatherService: WeatherClient) {
        self.weatherService = weatherService
    }
    
    func process(data: PacketDataArray, completion: @escaping ResultCompletion<PacketDataArray>) {
        do {
            _ = try BinaryDecoder.decode(UDPPacket<ForecastRequest>.self, data: data)
        } catch {
            completion(.error(error))
            return
        }
        
        let APIRequest = WeatherAPIRequest(location: Location.London())
        weatherService.send(APIRequest) { response in
            switch(response) {
            case let .error(error):
                completion(.error(error))
            case let .success(result):
                do {
                    let data = try self.processAPIForecast(forecast: result.forecast)
                    completion(.success(data))
                } catch {
                    completion(.error(error))
                }
            }
        }
    }

    private func processAPIForecast(forecast: [WeatherForecast]) throws -> PacketDataArray {
        let today = forecast[0]
        let firstDay = forecast[1]
        let secondDay = forecast[2]
        let thirdDay = forecast[3]
        let forthDay = forecast[4]
        let weatherNow = WeatherForecastBin(icon: WeatherForecastBin.Icon(today.icon),
                                            tempMax: today.temperatureMax,
                                            tempMin: today.temperatureMin)
        let binForecast1 = WeatherForecastBin(icon: WeatherForecastBin.Icon(firstDay.icon),
                                              tempMax: firstDay.temperatureMax,
                                              tempMin: firstDay.temperatureMin)
        let binForecast2 = WeatherForecastBin(icon: WeatherForecastBin.Icon(secondDay.icon),
                                              tempMax: secondDay.temperatureMax,
                                              tempMin: secondDay.temperatureMin)
        let binForecast3 = WeatherForecastBin(icon: WeatherForecastBin.Icon(thirdDay.icon),
                                              tempMax: thirdDay.temperatureMax,
                                              tempMin: thirdDay.temperatureMin)
        let binForecast4 = WeatherForecastBin(icon: WeatherForecastBin.Icon(forthDay.icon),
                                              tempMax: forthDay.temperatureMax,
                                              tempMin: forthDay.temperatureMin)
        
        let forecast = NextDaysForecastPacket(country: Country.uk,
                                              date: today.date,
                                              today: weatherNow,
                                              day1: binForecast1,
                                              day2: binForecast2,
                                              day3: binForecast3,
                                              day4: binForecast4)
        
        return try BinaryEncoder.encode(forecast)
    }
}
