//
//  WeatherStationRequestHandler.swift
//  WeatherRESTClient
//
//  Created by Fabio Gallonetto on 24/02/2019.
//

import Foundation
import WeatherRESTClient
import WeatherUDPProtocol

extension APIError : CustomStringConvertible {
    public var description: String {
        switch(self) {
        case .invalidHTTPStatusCode:
            return "Invalid HTTP status code"
        case .invalidHTTPResponse:
            return "Invalid HTTP response format"
        case .noData:
            return "No data received"
        case let .unableToParse(error):
            return error.localizedDescription
        }
    }
}


class WeatherUDPRequestHandler: UDPRequestHandler {
    
    enum Error: Swift.Error {
        case invalidIP(String)
        case noClientWaitingForResponse
    }
    
    let realWeatherServer: SocketAddress
    
    private var clientAwaitingResponse: SocketAddress?
    
    var dataProcessors: [WeatherUDPRequestProcessor] = []
    
    init(originalServer: String, port: UInt16) throws {
        guard let address = SocketAddress(with: originalServer, port: port) else {
            throw Error.invalidIP(originalServer)
        }
        self.realWeatherServer = address
    }
    
    func process(data: Data, from: SocketAddress, completion: @escaping ResultCompletion<UDPRequestHandlerResponse?>) {
        let dataArray = Array<UInt8>(data)
        if let cmd = try? UDPPacketUtils.inspectDataForCommandID(data: dataArray) {
            print("Received command: \(cmd)")
        } else {
            print("Received unknown command!")
        }
        let dataString = dataArray.reduce("") { $0 + String(format:"%02X", $1) }
        print("Full data: \(dataString)")
        
        let processor = dataProcessors.first { $0.canHandle(data: dataArray) }
        guard from != realWeatherServer else {
            print("Message is coming back from original server... forwarding to client")
            guard let clientAwaitingResponse = clientAwaitingResponse else {
                completion(.error(Error.noClientWaitingForResponse))
                return
            }
            let dataString = data.reduce("") { $0 + String(format:"%02X", $1) }
            print("Full response: \(dataString)")
            completion(.success(UDPRequestHandlerResponse(data: data, to:clientAwaitingResponse)))
            self.clientAwaitingResponse = nil
            return
        }
        
        guard processor != nil else {
            print("Unable to find processors for the data - forwarding packet to original server")
            self.clientAwaitingResponse = from
            completion(.success(UDPRequestHandlerResponse(data: data, to: self.realWeatherServer)))
            return
        }
        
        // need ot send to server here too, not only ebelow
        processor?.process(data: dataArray) { result in
            switch(result) {
            case .error(let error):
                completion(.error(error))
                self.clientAwaitingResponse = nil
            case .success(let responseData):
                
                let dataString = responseData.reduce("") { $0 + String(format:"%02X", $1) }
                print("Full response: \(dataString)")
                completion(.success(UDPRequestHandlerResponse(data: Data(bytes: responseData), to: from)))
            }
        }
    }
}
