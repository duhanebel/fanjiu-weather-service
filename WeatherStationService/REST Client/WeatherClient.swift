//
//  WeatherClient.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

struct Location {
    let latitude: Double
    let longitude: Double
}

extension Location {
    static func London() -> Location {
        return Location(latitude: 51.5102, longitude: 0.0350)
    }
}

struct WeatherRequestBuilder: APIRequestBuilder {
    let APIKey: String
    let scheme = "https"
    let host = "api.darksky.net"
    
    init(APIKey: String) {
        self.APIKey = APIKey
    }
    
    func build<T: APIRequest>(_ APIrequest: T) -> URLRequest {
        assert(APIrequest.type == .GET) // We only build get requests here
        
        var requestComponents = URLComponents()
        requestComponents.scheme = self.scheme
        requestComponents.host = self.host
        requestComponents.path = "/forecast/\(self.APIKey)/\(APIrequest.path)"
        requestComponents.queryItems = APIrequest.parameters.map { URLQueryItem(name: $0, value: $1) }
        var request =  URLRequest(url: requestComponents.url!)
        for (key, value) in APIrequest.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}

class WeatherClient : APIClient {
    let builder: APIRequestBuilder
    let session: URLSession
    
    init(builder: APIRequestBuilder, session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
        self.builder = builder
    }
}

enum UnitsFormat: String {
    case si
    case uk2
    case us
    case ca
}

struct WeatherAPIRequest: APIRequest {
    typealias Payload = WeatherAPIResponse
    
    let location: Location
    let unitsFormat: UnitsFormat = .ca
    
    var path: String {
        return "\(location.latitude),\(location.longitude)"
    }
    
    var headers: Dictionary<String, String> {
        return [:]
    }
    var type: RequestType {
        return RequestType.GET
    }
    
    var parameters: Dictionary<String, String> {
        return ["lang": "en",
                "units": unitsFormat.rawValue,
                "exclude": "minutely,hourly,alerts,flags"]
    }
}
