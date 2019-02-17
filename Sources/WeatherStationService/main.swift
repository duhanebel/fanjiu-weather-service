//
//  main.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 26/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation
import WeatherRESTClient

//var networkGroup = DispatchGroup()
//networkGroup.enter()



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
        let processor = dataProcessors.first { $0.canHandle(data: dataArray) }
        guard from != realWeatherServer else {
            print("Message is coming back from original server... forwarding to client")
            guard let clientAwaitingResponse = clientAwaitingResponse else {
                completion(.error(Error.noClientWaitingForResponse))
                return
            }
            
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
                completion(.success(UDPRequestHandlerResponse(data: Data(bytes: responseData), to: from)))
            }
        }
    }
}


let APIKey: String
do {
    APIKey = try String(contentsOfFile: "api_key.txt").replacingOccurrences(of: "[^A-Za-z0-9]+", with: "", options: [.regularExpression])
} catch {
    print("Unable to find api_key.txt")
    exit(-1)
}

let london = Location.London()
var weatherClient = WeatherClient(builder: WeatherRequestBuilder(APIKey: APIKey))

let reqProcessor = try! WeatherUDPRequestHandler(originalServer: "47.52.149.125", port: 10000)
//reqProcessor.dataProcessors.append(HelloUDPRequestProcessor()) Might be needed to register the station.. who knows!


// Re-route the important ones!
reqProcessor.dataProcessors.append(ForecastUDPRequestProcessor(weatherService: weatherClient))
reqProcessor.dataProcessors.append(CurrentWeatherUDPRequestProcessor(weatherService: weatherClient))


let server = try UDPServer(processor: reqProcessor, bindIP: nil, bindPort: 10000)
try server.start()
print("Press CTRL+D to exit")
print()

while let _ = readLine(){}
