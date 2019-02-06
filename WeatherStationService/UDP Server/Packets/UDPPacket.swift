//
//  UDPPacket.swift
//  WeatherStationService
//
//  Created by Fabio Gallonetto on 06/02/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import Foundation

struct UDPPacket<T: BinaryCodable>: BinaryCodable {
    let header: Header
    let mac: MACAddress
    let command: ResponseCommand
    let payloadSize: UInt16 // TODO fix this up on tests and parsing!
    let stationID: UInt8
    let country: Country
    let date: Date
    let payload: T
    let checksum: Checksum
    let footer: Footer
    
    init(command: ResponseCommand, mac: MACAddress, country: Country, date:Date, payload: T) {
        // Size is from command onward
        let commandSize = UInt16(
            1 + // station ID is 1
            MemoryLayout<Country>.size +
            5 +// Date is MM:DD:hh:mm:ss
            MemoryLayout<T>.size)
        
        self.header = Header.default
        self.command = command
        self.mac = mac
        self.stationID = UInt8(1) // We only support one station
        self.payloadSize = commandSize
        self.country = country
        self.date = date
        self.payload = payload
        self.checksum = Checksum()
        self.footer = Footer.default
    }
}
