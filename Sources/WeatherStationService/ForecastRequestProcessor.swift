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
            self = .cloudy
        case .rain:
            self = .heavyRain
        case .snow:
            self = .heavySnow
        case .sleet:
            self = .rainAndSnow
        case .wind:
            self = .windy
        case .fog:
            self = .foggy
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
    let location: Location
    
    init(weatherService: WeatherClient, location: Location = Location.London()) {
        self.weatherService = weatherService
        self.location = location
    }
    
    func process(data: PacketDataArray, completion: @escaping ResultCompletion<PacketDataArray>) {
        let forecastRequest:UDPPacket<ForecastRequest>
        do {
            forecastRequest = try BinaryDecoder.decode(UDPPacket<ForecastRequest>.self, data: data)
        } catch {
            completion(.error(error))
            return
        }
        
        let APIRequest = WeatherAPIRequest(location: location, unitsFormat: .us)
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
                                            tempMax: Temperature(fahrenheit: today.temperatureMax.rounded()),
                                            tempMin: Temperature(fahrenheit: today.temperatureMin.rounded()))
        let binForecast1 = WeatherForecastBin(icon: WeatherForecastBin.Icon(firstDay.icon),
                                              tempMax: Temperature(fahrenheit: firstDay.temperatureMax.rounded()),
                                              tempMin: Temperature(fahrenheit: firstDay.temperatureMin.rounded()))
        let binForecast2 = WeatherForecastBin(icon: WeatherForecastBin.Icon(secondDay.icon),
                                              tempMax: Temperature(fahrenheit: secondDay.temperatureMax.rounded()),
                                              tempMin: Temperature(fahrenheit: secondDay.temperatureMin.rounded()))
        let binForecast3 = WeatherForecastBin(icon: WeatherForecastBin.Icon(thirdDay.icon),
                                              tempMax: Temperature(fahrenheit: thirdDay.temperatureMax.rounded()),
                                              tempMin: Temperature(fahrenheit: thirdDay.temperatureMin.rounded()))
        let binForecast4 = WeatherForecastBin(icon: WeatherForecastBin.Icon(forthDay.icon),
                                              tempMax: Temperature(fahrenheit: forthDay.temperatureMax.rounded()),
                                              tempMin: Temperature(fahrenheit: forthDay.temperatureMin.rounded()))
        
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
