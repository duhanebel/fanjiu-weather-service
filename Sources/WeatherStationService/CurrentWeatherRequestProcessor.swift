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
    let location: Location
    
    init(weatherService: WeatherClient, location: Location = Location.London()) {
        self.weatherService = weatherService
        self.location = location
    }
    
    func process(data: PacketDataArray, completion: @escaping ResultCompletion<PacketDataArray>) {
        let request: UDPPacket<CurrentWeatherRequest>
        do {
            request = try BinaryDecoder.decode(UDPPacket<CurrentWeatherRequest>.self, data: data)
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
                                          feelsLike: Temperature(fahrenheit: weather.feelsLike.rounded()),
                                          pressure: weather.pressure.rounded(),
                                          windSpeed: (weather.windSpeed.mphToKm.rounded()),
                                          windDirectionDegrees: weather.windDirection)
        
        let packet = UDPPacket<CurrentWeatherPacket>(command: Command(commandID: .responseCurrentWeather), mac: request.mac, payload: weather)
        return try BinaryEncoder.encode(packet)
    }
}

extension Float {
    var mphToKm: Float {
        return self * 1.60934
    }
    var kmToMph: Float {
        return self / 1.60934
    }
}
