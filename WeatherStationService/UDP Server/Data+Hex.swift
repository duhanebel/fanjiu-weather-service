//
//  Data+Hex.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

extension Data {
    public init(hex: String) {
        self.init(bytes: Array<UInt8>(hex: hex))
    }
}
