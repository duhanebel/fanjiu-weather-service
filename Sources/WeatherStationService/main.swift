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

let port = 10000

class WeatherUDPProcessor: RequestProcessor {
    
    let realWeatherServer = SocketAddress(with: "47.52.149.125", port: 10000)!
    
    private var clientAwaitingResponse: SocketAddress?
    
    var dataProcessors: [WeatherUDPRequestProcessor] = []
    
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
let reqProcessor = WeatherUDPProcessor()
reqProcessor.dataProcessors.append(HelloUDPRequestProcessor())
reqProcessor.dataProcessors.append(ForecastUDPRequestProcessor())
//let server = WeatherUDPServer(port: port, requestProcessor: reqProcessor)
//print("Swift Echo Server Sample")
//print("Connect with a command line window by entering 'telnet ::1 \(port)'")
//
//server.run()

//networkGroup.wait()

print()
print("Hello, World! Echo UDP Server is listenig ...")
print("Connect any number of clients /nc -u host port, .../ to any of:")
print()

let server = UDPServer(processor: reqProcessor)
server.start()
print("Press CTRL+D to exit")
print()


while let input = readLine(){}


