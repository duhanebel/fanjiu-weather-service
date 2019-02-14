//
//  CurrentWeatherRequestProcessor.swift
//  WeatherRESTClient
//
//  Created by Fabio Gallonetto on 14/02/2019.
//

import Foundation
import WeatherUDPProtocol
import WeatherRESTClient

struct CurrentWeatherUDPRequestProcessor: WeatherUDPRequestProcessor {
    static var commands = [CommandID.requestCurrentWeather]
    
    var weatherService: WeatherClient
    
    init(weatherService: WeatherClient) {
        self.weatherService = weatherService
    }
    
    func process(data: PacketDataArray, completion: @escaping ResultCompletion<PacketDataArray>) {
        do {
            _ = try BinaryDecoder.decode(UDPPacket<CurrentWeatherRequest>.self, data: data)
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
                    let data = try self.processAPIWeather(result.currently)
                    completion(.success(data))
                } catch {
                    completion(.error(error))
                }
            }
        }
    }
    
    
    private func processAPIWeather(_ weather: WeatherNow) throws -> PacketDataArray {
        let packet = CurrentWeatherPacket(country: Country.uk,
                                          date: Date(),
                                          feelsLike: weather.feelsLike,
                                          pressure: weather.pressure,
                                          windSpeed: weather.windSpeed,
                                          windDirectionDegrees: weather.windDirection)
        return try BinaryEncoder.encode(packet)
    }
}
