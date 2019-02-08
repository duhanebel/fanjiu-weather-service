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

    
    let realWeatherServer = (ip: "47.52.149.125", port: 10000)
    
    private var clientAwaitingResponse: (ip: String, port: Int)?
    
    var dataProcessors: [WeatherUDPRequestProcessor] = []
    
    func process(data: Data, from: String, port: Int) throws -> (data: Data, destIP: String, port: Int)? {
        let dataArray = Array<UInt8>(data)
        let processor = dataProcessors.first { $0.canHandle(data: dataArray) }
        if let responseData = try processor?.process(data: dataArray) {
            return (data: Data(bytes: responseData), destIP: from, port: port)
        } else {
            if let clientAwaitingResponse = clientAwaitingResponse,
                from == realWeatherServer.ip {
                self.clientAwaitingResponse = nil
                return (data: data, destIP: clientAwaitingResponse.ip, port: clientAwaitingResponse.port)
            } else {
                clientAwaitingResponse = (ip: from, port: port)
                return (data: data, destIP: realWeatherServer.ip, port: realWeatherServer.port)
            }
        }
    }
}

let reqProcessor = WeatherUDPProcessor()
reqProcessor.dataProcessors.append(ForecastUDPRequestProcessor())
let server = WeatherUDPServer(port: port, requestProcessor: reqProcessor)
print("Swift Echo Server Sample")
print("Connect with a command line window by entering 'telnet ::1 \(port)'")

server.run()

//networkGroup.wait()
