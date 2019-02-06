//
//  RequestHandler.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 28/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

struct WeatherRequest {
    
}

typealias RequestHandler = ()->()

protocol RequestCreator {
    func handles(requets: WeatherRequest) -> Bool
    func handle(request: WeatherRequest) -> RequestHandler
}
