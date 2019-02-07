//
//  APIClient.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 26/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation


public enum RequestType: String {
    case GET = "GET"
    case POST = "POST"
}

public protocol APIRequest {
    associatedtype Payload: Decodable
    
    var path: String { get }
    var headers: Dictionary<String, String> { get }
    var parameters: Dictionary<String, String> { get }
    var type: RequestType { get }
}



public protocol APIRequestBuilder {
    func build<T: APIRequest>(_: T) -> URLRequest
}

public typealias APIClientSendCallback<T> = (Result<T>) -> Void

public protocol APIClient {
    var builder: APIRequestBuilder { get }
    var session: URLSession { get }
    func send<T: APIRequest>(_: T, completion: @escaping APIClientSendCallback<T.Payload>)
}

extension APIClient {
    public func send<T: APIRequest>(_ request: T, completion: @escaping APIClientSendCallback<T.Payload>) {
        let URLrequest = builder.build(request)
        let task = session.dataTask(with: URLrequest) { data, response, error in  // T##(Data?, URLResponse?, Error?) -> Void)
            guard error == nil else {
                completion(.error(error!))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.error(APIError.invalidHTTPResponse))
                return
            }
            
            if(httpResponse.statusCode != 200) {
                completion(.error(APIError.invalidHTTPStatusCode))
                return
            }
            
            guard let data = data else {
                completion(.error(APIError.noData))
                return
            }
            
            var result : T.Payload
            do {
                result = try JSONDecoder().decode(T.Payload.self, from: data)
            } catch {
                completion(.error(APIError.unableToParse(error)))
                return
            }
            
            completion(.success(result))
            
        }
        task.resume()
    }
}
