//
//  LaunchArgumentParser.swift
//  Basic
//
//  Created by Fabio Gallonetto on 24/02/2019.
//

import Foundation
import Utility

extension Double: ArgumentKind {
    public init(argument: String) throws {
        guard let float = Double(argument) else {
            throw ArgumentConversionError.typeMismatch(value: argument, expectedType: Double.self)
        }
        
        self = float
    }
    
    public static let completion: ShellCompletion = .none
}

struct WeatherServiceArgumentParser {
    let arguments: [String]
    
    private var parsedArguments: ArgumentParser.Result? = nil
    
    private let bindIPArg: OptionArgument<String>
    private let bindPortArg: OptionArgument<Int>
    private let latitudeArg: OptionArgument<Double>
    private let longitudeArg: OptionArgument<Double>
    private let fanjuIPArg: OptionArgument<String>
    private let fanjuPortArg: OptionArgument<Int>
    
    var parser: ArgumentParser
    
    init(pInfo: ProcessInfo) {
        // The first argument is always the executable, drop it
        self.init(arguments: Array(pInfo.arguments.dropFirst()))
    }
    
    init(arguments: [String]) {
        self.arguments = arguments
        
        parser = ArgumentParser(usage: "<options>", overview: "Weather proxy service DarkSky-->Fanju station")
        bindIPArg = parser.add(option: "--bind-ip", shortName: "-i", kind: String.self, usage: "IP to bind to (default: all)")
        bindPortArg = parser.add(option: "--bind-port", shortName: "-p", kind: Int.self, usage: "Port to bind to (default 10000)")
        latitudeArg = parser.add(option: "--lat", shortName: "-o", kind: Double.self, usage: "Latitude of location to check weather of (default London)")
        longitudeArg = parser.add(option: "--lon", shortName: "-a", kind: Double.self, usage: "Longitude of location to check weather of (default London)")
        fanjuIPArg = parser.add(option: "--fanju-ip", shortName: "-p", kind: String.self, usage: "IP of the fanju weather service (default 47.52.149.125)")
        fanjuPortArg = parser.add(option: "--fanju-port", shortName: "-r", kind: Int.self, usage: "Port of the fanju weather service (default 10000)")
    }
    
    mutating func parse() throws {
        self.parsedArguments = try parser.parse(arguments)
    }
    
    var bindIP: String? {
        return parsedArguments?.get(bindIPArg)
    }
    
    var bindPort: UInt16 {
        return UInt16(parsedArguments?.get(bindPortArg) ?? 10000)
    }
    
    var location: (latitude: Double, longitude: Double)? {
        if let latitude = parsedArguments?.get(latitudeArg),
            let longitude = parsedArguments?.get(longitudeArg) {
            return (latitude:latitude, longitude:longitude)
        } else {
            return nil
        }
    }
    
    var fanjuIP: String {
        return parsedArguments?.get(fanjuIPArg) ?? "47.52.149.125"
    }
    
    var fanjuPort: UInt16 {
        return UInt16(parsedArguments?.get(fanjuPortArg) ?? 10000)
    }
}
