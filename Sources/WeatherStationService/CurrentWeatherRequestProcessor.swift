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
        let request: UDPPacket<CurrentWeatherRequest>
        do {
            request = try BinaryDecoder.decode(UDPPacket<CurrentWeatherRequest>.self, data: data)
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
                    let data = try self.processAPIWeather(result.currently, for: request)
                    completion(.success(data))
                } catch {
                    completion(.error(error))
                }
            }
        }
    }
    
    
    private func processAPIWeather(_ weather: WeatherNow, for request: UDPPacket<CurrentWeatherRequest>) throws -> PacketDataArray {
        let weather = CurrentWeatherPacket(country: Country.uk,
                                          date: Date(),
                                          feelsLike: Temperature(celsius: weather.feelsLike),
                                          pressure: weather.pressure,
                                          windSpeed: weather.windSpeed,
                                          windDirectionDegrees: weather.windDirection)
        
        let packet = UDPPacket<CurrentWeatherPacket>(command: Command(commandID: .responseCurrentWeather), mac: request.mac, payload: weather)
        return try BinaryEncoder.encode(packet)
    }
}
