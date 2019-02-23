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
        case .sunnyDay, .sunnyNight:
            self = .sunny
        case .cloudy:
            self = .mostlyCloudy //.cloudy
        case .rain:
            self = .heavyRain
        case .snow:
            self = .heavyRain //.heavySnow
        case .sleey:
            self = .heavyRain //.rainAndSnow
        case .wind:
            self = .sunny //.windy
        case .fog:
            self = .mostlyCloudy //.foggy
        case .partCloudyDay, .partCloudyNight:
            self = .partiallyCloudy
        }
    }
}

private extension Float {
    func toFarheneight() {
        
    }
}

struct ForecastUDPRequestProcessor: WeatherUDPRequestProcessor {
    static var commands = [CommandID.requestForecast]
    
    var weatherService: WeatherClient
    
    init(weatherService: WeatherClient) {
        self.weatherService = weatherService
    }
    
    func process(data: PacketDataArray, completion: @escaping ResultCompletion<PacketDataArray>) {
        let forecastRequest:UDPPacket<ForecastRequest>
        do {
            forecastRequest = try BinaryDecoder.decode(UDPPacket<ForecastRequest>.self, data: data)
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
                    let data = try self.processAPIForecast(forecast: result.forecast, for: forecastRequest)
                    completion(.success(data))
                } catch {
                    completion(.error(error))
                }
            }
        }
    }

    private func processAPIForecast(forecast: [WeatherForecast], for request: UDPPacket<ForecastRequest>) throws -> PacketDataArray {
        let today = forecast[0]
        let firstDay = forecast[1]
        let secondDay = forecast[2]
        let thirdDay = forecast[3]
        let forthDay = forecast[4]
        let weatherNow = WeatherForecastBin(icon: WeatherForecastBin.Icon(today.icon),
                                            tempMax: Temperature(celsius: today.temperatureMax),
                                            tempMin: Temperature(celsius: today.temperatureMin))
        let binForecast1 = WeatherForecastBin(icon: WeatherForecastBin.Icon(firstDay.icon),
                                              tempMax: Temperature(celsius: firstDay.temperatureMax),
                                              tempMin: Temperature(celsius: firstDay.temperatureMin))
        let binForecast2 = WeatherForecastBin(icon: WeatherForecastBin.Icon(secondDay.icon),
                                              tempMax: Temperature(celsius: secondDay.temperatureMax),
                                              tempMin: Temperature(celsius: secondDay.temperatureMin))
        let binForecast3 = WeatherForecastBin(icon: WeatherForecastBin.Icon(thirdDay.icon),
                                              tempMax: Temperature(celsius: thirdDay.temperatureMax),
                                              tempMin: Temperature(celsius: thirdDay.temperatureMin))
        let binForecast4 = WeatherForecastBin(icon: WeatherForecastBin.Icon(forthDay.icon),
                                              tempMax: Temperature(celsius: forthDay.temperatureMax),
                                              tempMin: Temperature(celsius: forthDay.temperatureMin))
        
        let forecast = NextDaysForecastPacket(country: Country.uk,
                                              date: Date(),
                                              today: weatherNow,
                                              day1: binForecast1,
                                              day2: binForecast2,
                                              day3: binForecast3,
                                              day4: binForecast4)
        let packet = UDPPacket<NextDaysForecastPacket>(command: Command(commandID: .responseForecast), mac: request.mac, payload: forecast)
        return try BinaryEncoder.encode(packet)
    }
}
