//
//  RequestProcessors.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 07/02/2019.
//

import Foundation
import WeatherUDPProtocol

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
        
        let responsePacket = UDPPacket<HelloResponse>(command: Command(commandID: .responseHello), mac:request.mac, country: request.country, date:Date(), payload: HelloResponse())
       
        let responseData = try BinaryEncoder.encode(responsePacket)
        return responseData
    }
}

struct ForecastUDPRequestProcessor: WeatherUDPRequestProcessor {
    static var commands = [CommandID.requestForecast]
    
    func process(data: PacketDataArray) throws -> PacketDataArray {
//        let request = try BinaryDecoder.decode(UDPPacket<HelloRequest>.self, data: data)
//
//        let responsePacket = UDPPacket<HelloResponse>(command: Command(commandID: .responseHello), mac:request.mac, country: request.country, date:Date(), payload: HelloResponse())
//
//        let responseData = try BinaryEncoder.encode(responsePacket)
        return PacketDataArray(hex: "00:FF:00")
    }
}


//class ForwardingUDPRequestProcessor: WeatherUDPRequestProcessor {
//    static var commands = []
//    
//    let UDPClient: UDPClient = UDPClient()
//    
//    func canHandle(data: PacketDataArray) -> Bool {
//        return true
//    }
//    func process(data: PacketDataArray) throws -> PacketDataArray {
//        let binData = Data(bytes: data)
//        
//        
//        
//        
//        let response = PacketDataArray(resData)
//    }
//}
