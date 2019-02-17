//
//  Temperature+BinaryCodable.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 02/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

public struct Temperature {
    public let fahrenheit: Float
    public var celsius: Float {
        return ((fahrenheit * 5/9) - 32).rounded() }
    
    public init(celsius: Float) {
        fahrenheit = ((celsius * 9/5) + 32).rounded()
    }
    
    public init(fahrenheit: Float) {
        self.fahrenheit = fahrenheit
    }
}

extension Temperature: Sizeable {
    public var size: Int { return MemoryLayout<UInt16>.size }
}

extension Temperature: Equatable {
    public static func == (lhs: Temperature, rhs: Temperature) -> Bool {
        return lhs.fahrenheit == rhs.fahrenheit
    }
}

extension Temperature : BinaryCodable {
    public func binaryEncode(to encoder: BinaryEncoder) throws {
        let encodedTemp = 90 + fahrenheit
        try encoder.encode(encodedTemp)
    }
    
    public init(fromBinary decoder: BinaryDecoder) throws {
        let encodedTemp = try decoder.decode(Float.self)
        fahrenheit = (encodedTemp - 90)
    }
}
