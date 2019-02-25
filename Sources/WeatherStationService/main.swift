//
//  main.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 26/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation
import WeatherRESTClient
import Utility


//var networkGroup = DispatchGroup()
//networkGroup.enter()



var parser = WeatherServiceArgumentParser(pInfo: ProcessInfo.processInfo)

//var parser = WeatherServiceArgumentParser(arguments: ["--bind-ip", "1.1.1", "--bind-port", "101", "--lat", "1.2323", "--lon", "-1.023"])


do {
    try parser.parse()
}
catch let error as ArgumentParserError {
    print(error.description)
}
catch let error {
    print(error.localizedDescription)
}

let APIKey: String
do {
    APIKey = try String(contentsOfFile: "api_key.txt").replacingOccurrences(of: "[^A-Za-z0-9]+", with: "", options: [.regularExpression])
} catch {
    print("Unable to find api_key.txt")
    exit(-1)
}

let location: Location
if let coordinates = parser.location {
    location = Location(latitude: coordinates.latitude, longitude: coordinates.longitude)
} else {
    location = Location.London()
}

var weatherClient = WeatherClient(builder: WeatherRequestBuilder(APIKey: APIKey))
let reqProcessor = try! WeatherUDPRequestHandler(originalServer: parser.fanjuIP, port: parser.fanjuPort)

// Re-route weather responses
reqProcessor.dataProcessors.append(ForecastUDPRequestProcessor(weatherService: weatherClient, location: location))
reqProcessor.dataProcessors.append(CurrentWeatherUDPRequestProcessor(weatherService: weatherClient, location: location))

let server = try UDPServer(processor: reqProcessor, bindIP: parser.bindIP, bindPort: parser.bindPort)
try server.start()
print("Press CTRL+D to exit")
print()

while let _ = readLine(){}
