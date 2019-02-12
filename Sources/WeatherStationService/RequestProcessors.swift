//
//  RequestProcessors.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 07/02/2019.
//

import Foundation
import WeatherUDPProtocol
import WeatherRESTClient

protocol WeatherUDPRequestProcessor {
    static var commands: [CommandID] { get }
    func canHandle(data: PacketDataArray) -> Bool
    func process(data: PacketDataArray) throws -> PacketDataArray
}

extension WeatherUDPRequestProcessor {
    func canHandle(data: PacketDataArray) -> Bool {
        if let cmd = try? UDPPacketUtils.inspectDataForCommandID(data: data) {
            return Self.commands.contains(cmd)
        } else {
            return false
        }
    }
}

struct HelloUDPRequestProcessor: WeatherUDPRequestProcessor {
    static var commands = [CommandID.requestHello]
    
    func process(data: PacketDataArray) throws -> PacketDataArray {
        let request = try BinaryDecoder.decode(UDPPacket<HelloRequest>.self, data: data)
        
        let responsePacket = UDPPacket<HelloResponse>(command: Command(commandID: .responseHello), mac:request.mac, payload: HelloResponse())
       
        let responseData = try BinaryEncoder.encode(responsePacket)
        return responseData
    }
}

//protocol weatherProvider {
//    func fetchWeather()
//    var weatherService: WeatherClient { get }
//}
//
//struct ForecastUDPRequestProcessor: WeatherUDPRequestProcessor {
//    static var commands = [CommandID.requestForecast]
//
//    var weatherService: WeatherClient
//
//    init(weatherService: WeatherClient) {
//        self.weatherService = weatherService
//    }
//
//    func process(data: PacketDataArray) throws -> PacketDataArray {
//        let request = try BinaryDecoder.decode(UDPPacket<HelloRequest>.self, data: data)
//
//        let APIRequest = WeatherAPIRequest(location: Location.London())
////        client.send(APIRequest) { result in
////            switch(response) {
////                    case let .error(error as APIError):
////                        print(error.description)
////                        exit(-1)
////                    case let .error(error):
////                        print(error.localizedDescription)
////                        exit(-1)
////                    case let .success(result):
////            }
////
////            // This is async, need to make it sync or find a way out!
//
//
////        let weatherForecast = CurrentWeatherPacket(country: Country.uk, date: Date(), feelsLike: <#T##Float#>, pressure: <#T##Float#>, windSpeed: <#T##Float#>, windDirection: <#T##UInt8#>)
////        let responsePacket = UDPPacket<HelloResponse>(command: Command(commandID: .responseHello), mac:request.mac, country: request.country, date:Date(), payload: HelloResponse())
//
//        let responseData = try BinaryEncoder.encode(responsePacket)
//        return responseData
//    }
//}
//
//
////class ForwardingUDPRequestProcessor: WeatherUDPRequestProcessor {
////    static var commands = []
////
////    let UDPClient: UDPClient = UDPClient()
////
////    func canHandle(data: PacketDataArray) -> Bool {
////        return true
////    }
////    func process(data: PacketDataArray) throws -> PacketDataArray {
////        let binData = Data(bytes: data)
////
////
////
////
////        let response = PacketDataArray(resData)
////    }
////}
