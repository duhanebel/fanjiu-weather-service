//
//  UDPClient.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 07/02/2019.
//

import Foundation
import Socket

protocol UDPClient {
    func send(data: Data) throws -> Data
}


class SocketUDPClient: UDPClient {
    let server: String
    let port: Int32
    let socket: Socket
    
    private var address: Socket.Address {
        return Socket.createAddress(for: server, on: port)! // TODO propagate exception
    }
    
    init(server: String, port: Int32, socket: Socket? = nil) throws {
        self.socket = try socket ?? Socket.create(family: .inet, type: .datagram, proto: .udp)
        self.server = server
        self.port = port
    }
    
    
    func send(data: Data) throws -> Data {
        try socket.write(from: data, to: address)
        var responseData = Data()
        _ = try socket.readDatagram(into: &responseData)
        return responseData
    }
}
