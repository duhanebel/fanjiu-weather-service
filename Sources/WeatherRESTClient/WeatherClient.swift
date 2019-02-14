//
//  WeatherClient.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct Location {
    public let latitude: Double
    public let longitude: Double
}

extension Location {
    public static func London() -> Location {
        return Location(latitude: 51.5102, longitude: 0.0350)
    }
}

public struct WeatherRequestBuilder: APIRequestBuilder {
    public let APIKey: String
    public let scheme = "https"
    public let host = "api.darksky.net"
    
    public init(APIKey: String) {
        self.APIKey = APIKey
    }
    
    public func build<T: APIRequest>(_ APIrequest: T) -> URLRequest {
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

public class WeatherClient : APIClient {
    public let builder: APIRequestBuilder
    public let session: URLSession
    
    public init(builder: APIRequestBuilder, session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
        self.builder = builder
    }
}

public enum UnitsFormat: String {
    case si
    case uk2
    case us
    case ca
}

public struct WeatherAPIRequest: APIRequest {
    public typealias Payload = WeatherAPIResponse
    
    public let location: Location
    public let unitsFormat: UnitsFormat

    public init(location: Location, unitsFormat: UnitsFormat = .ca) {
        self.location = location
        self.unitsFormat = unitsFormat
    }
    
    public var path: String {
        return "\(location.latitude),\(location.longitude)"
    }
    
    public var headers: Dictionary<String, String> {
        return [:]
    }
    public var type: RequestType {
        return RequestType.GET
    }
    
    public var parameters: Dictionary<String, String> {
        return ["lang": "en",
                "units": unitsFormat.rawValue,
                "exclude": "minutely,hourly,alerts,flags"]
    }
}
