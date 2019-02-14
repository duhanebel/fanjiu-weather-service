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
    func process(data: PacketDataArray, completion: @escaping ResultCompletion<PacketDataArray>)
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
    static var commands = [.requestHello]
    
    func process(data: PacketDataArray, completion: @escaping ResultCompletion<PacketDataArray>) {
        do {
            let request = try BinaryDecoder.decode(UDPPacket<HelloRequest>.self, data: data)
            let responsePacket = UDPPacket<HelloResponse>(command: Command(commandID: .responseHello), mac:request.mac, payload: HelloResponse())
            let responseData = try BinaryEncoder.encode(responsePacket)
            
            completion(.success(responseData))
        } catch {
            completion(.error(error))
        }
    }
}

protocol weatherProvider {
    func fetchWeather()
    var weatherService: WeatherClient { get }
}





