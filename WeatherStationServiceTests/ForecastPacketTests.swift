//
//  ForecastPacketTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 27/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest

class ForecastPacketTests: XCTestCase {
    var mockDate: Date = Date()
    let mockDateBinaryRep = PacketDataArray(hex: "03:01:0C:20:02")
    
    override func setUp() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        //according to date format your date string
        mockDate = dateFormatter.date(from: "12:32:02 01-03-2017")!
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWeatherForecastDataToPacketData() {
        let data = WeatherForecastData(icon: 0xFA, tempMin: 0x0, tempMax:0xA)
        let mockData = PacketDataArray(hex:"FA:FF:FF:78:05:c4:04")
        XCTAssertEqual(data.packetData, mockData)
        
        /*
         0d:ff:ff:0a:05:a6:04:  4 -2
         0d:ff:ff:1e:05:ec:04:  5  2
         00:ff:ff:28:05:74:04:  6 -4
         0d:ff:ff:46:05:4c:04:  7 -7
         */
        XCTAssertEqual(WeatherForecastData(icon: 0x0D, tempMin: -1.6, tempMax:4).packetData, PacketDataArray(hex:"0d:ff:ff:0a:05:a6:04"))
        XCTAssertEqual(WeatherForecastData(icon: 0x0D, tempMin: 2, tempMax:5).packetData, PacketDataArray(hex:"0d:ff:ff:1e:05:ec:04"))
        XCTAssertEqual(WeatherForecastData(icon: 0x0, tempMin: -4.7, tempMax:5.8).packetData, PacketDataArray(hex:"00:ff:ff:28:05:74:04"))
        XCTAssertEqual(WeatherForecastData(icon: 0x0D, tempMin: -6.7, tempMax:7.1).packetData, PacketDataArray(hex:"0d:ff:ff:46:05:4c:04"))
    }
    
    func testWeatherForecastToPacketData() {
        /*
 0d:ff:ff:1e:05:ce:04: Now 5 0.7
 0d:ff:ff:0a:05:a6:04:  4 -2
 0d:ff:ff:1e:05:ec:04:  5  2
 00:ff:ff:28:05:74:04:  6 -4
 0d:ff:ff:46:05:4c:04:  7 -7
 */
        let today = WeatherForecastData(icon: 0xFA, tempMin: 0.7, tempMax:5)
        let next = [WeatherForecastData(icon: 0xFA, tempMin: -1.6, tempMax:4),
                    WeatherForecastData(icon: 0xFA, tempMin: 2, tempMax:5),
                    WeatherForecastData(icon: 0xFA, tempMin: -4.7, tempMax:5.8),
                    WeatherForecastData(icon: 0xFA, tempMin: -6.7, tempMax:7.1)]
        let mac = PacketDataArray(hex: "AA:BB:CC:DD")
        let date = WeatherDate(date: mockDate)
        
        let data = ForecastPacket(date: date, today: today, next4Days: next, MACAddress: mac)
        let mockData = PacketDataArray(hex:"0C:13") + mockDateBinaryRep + PacketDataArray(
            hex:"FA:FF:FF:1e:05:ce:04:FA:FF:FF:0a:05:a6:04:FA:FF:FF:1e:05:ec:04:FA:FF:FF:28:05:74:04:FA:FF:FF:46:05:4c:04")
        XCTAssertEqual(data.payload, mockData)
    }
    
    func testWeatherDateToPacketData() {
        
        let mockWeatherDate = WeatherDate(date:mockDate)
        XCTAssertEqual(mockWeatherDate.packetData, mockDateBinaryRep)
    }
    
    func testTemperatureConversionCtoF() {
        let temp = WeatherTemperature(celsius: 0)
        XCTAssertEqual(temp.temp, 32)
    }
    
    func testTemperatureToPacketData() {
        XCTAssertEqual(WeatherTemperature(farenheit: 32).packetData, PacketDataArray(hex: "C4:04"))
        XCTAssertEqual(WeatherTemperature(farenheit: 51).packetData, PacketDataArray(hex: "82:05"))
        XCTAssertEqual(WeatherTemperature(farenheit: 20).packetData, PacketDataArray(hex: "4c:04"))
    }
    
    func testWeatherWindPressureToPacketData() {
        let val = WeatherWindPressure(value: 998)
        XCTAssertEqual(val.packetData, PacketDataArray(hex: "FC:26"))
    }
    
    func testWeatherDirectionToPacketData() {
        XCTAssertEqual(WindDirection(degrees: 90).packetData, PacketDataArray(hex:"04"))
        XCTAssertEqual(WindDirection(degrees: 180).packetData, PacketDataArray(hex:"08"))
        XCTAssertEqual(WindDirection(degrees: 360).packetData, PacketDataArray(hex:"00"))
        XCTAssertEqual(WindDirection(degrees: 45).packetData, PacketDataArray(hex:"02"))
        XCTAssertEqual(WindDirection(degrees: 0).packetData, PacketDataArray(hex:"00"))
    }
    
    func testCurrentWeatherToPacketData() {

        let mac = PacketDataArray(hex: "AA:BB:CC:DD")
        let date = WeatherDate(date: mockDate)
        
        let data = CurrentWeatherPacket(date: date, MACAddress: mac, feelsLike: 0, pressure: 998, windSpeed: 14, windDirection: 90)
        let mockData = PacketDataArray(hex:"0C:13") + mockDateBinaryRep + PacketDataArray(
            hex:"FF:FF:FF:FF:FF" + "C4:04" + "FC:26" + "8C:00" + "FF" + "5A" + "ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff")
        XCTAssertEqual(data.payload, mockData)
    }
}

