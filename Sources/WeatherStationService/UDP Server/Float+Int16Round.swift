//
//  Float+Int16Round.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 28/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

extension Float {
    var uint16Rounded: UInt16 {
        return UInt16(self.rounded())
    }
}
