//
//  APIError.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 26/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

enum APIError: Error {
    case invalidHTTPResponse
    case invalidHTTPStatusCode
    case noData
    case unableToParse(Error)
}
