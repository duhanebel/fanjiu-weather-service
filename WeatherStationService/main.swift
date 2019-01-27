//
//  main.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 26/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

print("Retrieving forecast")


let APIKey = "a972d998e8399e6ac25171267918c097"
let london = Location.London()

var networkGroup = DispatchGroup()
networkGroup.enter()

var client = WeatherClient(builder: WeatherRequestBuilder(APIKey: APIKey))

extension APIError : CustomStringConvertible {
    var description: String {
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

var request = WeatherAPIRequest(location: london)

client.send(request) { response in
    
    switch(response) {
    case let .error(error as APIError):
        print(error.description)
        exit(-1)
    case let .error(error):
        print(error.localizedDescription)
        exit(-1)
    case let .success(result):
        print(result.currently)
        print(result.forecast[1])
        print(result.forecast[2])
        print(result.forecast[3])
        print(result.forecast[4])
    }
    networkGroup.leave()
}

networkGroup.wait()
