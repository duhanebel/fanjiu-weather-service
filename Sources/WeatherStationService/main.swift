//
//  main.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 26/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation
import WeatherRESTClient

print("Retrieving forecast")

let APIKey = "a972d998e8399e6ac25171267918c097"
let london = Location.London()

//var networkGroup = DispatchGroup()
//networkGroup.enter()

var client = WeatherClient(builder: WeatherRequestBuilder(APIKey: APIKey))

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

//var request = WeatherAPIRequest(location: london)
//
//client.send(request) { response in
//    
//    switch(response) {
//    case let .error(error as APIError):
//        print(error.description)
//        exit(-1)
//    case let .error(error):
//        print(error.localizedDescription)
//        exit(-1)
//    case let .success(result):
//        print(result.currently)
//        print(result.forecast[1])
//        print(result.forecast[2])
//        print(result.forecast[3])
//        print(result.forecast[4])
//    }
//    networkGroup.leave()
//}

class WeatherUDPRequestHandler: UDPRequestHandler {
    
    enum Error: Swift.Error {
        case invalidIP(String)
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
    
    func process(data: Data, from: SocketAddress) throws -> (data: Data, to: SocketAddress)? {
        let dataArray = Array<UInt8>(data)
        let processor = dataProcessors.first { $0.canHandle(data: dataArray) }
        if processor == nil {
            print("Unable to find processors for the data: sending to server")
        }
        if let responseData = try processor?.process(data: dataArray) {
            return (data: Data(bytes: responseData), to: from)
        } else {
            if let clientAwaitingResponse = clientAwaitingResponse,
                from == realWeatherServer {
                self.clientAwaitingResponse = nil
                return (data: data, to: clientAwaitingResponse)
            } else {
                clientAwaitingResponse = from
                return (data: data, to: realWeatherServer)
            }
        }
    }
}
//
let reqProcessor = try! WeatherUDPRequestHandler(originalServer: "47.52.149.125", port: 10000)
reqProcessor.dataProcessors.append(HelloUDPRequestProcessor())
reqProcessor.dataProcessors.append(ForecastUDPRequestProcessor())


let server = try UDPServer(processor: reqProcessor, bindIP: nil, bindPort: 10000)
try server.start()
print("Press CTRL+D to exit")
print()

while let _ = readLine(){}
