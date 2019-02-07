//
//  Result.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 26/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case error(Error)
}
