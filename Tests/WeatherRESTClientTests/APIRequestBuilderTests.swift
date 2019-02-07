//
//  WeatherStationServiceTests.swift
//  WeatherStationServiceTests
//
//  Created by Fabio Gallonetto on 26/01/2019.
//  Copyright © 2019 Fabio Gallonetto. All rights reserved.
//

import XCTest
import WeatherRESTClient

struct MockPayload: Decodable {}

struct MockAPIRequest: APIRequest {
    typealias Payload = MockPayload
    var path = "mypath/mysecondpath"
    var headers = [ "header1": "hvalue1", "header2": "hvalue2"]
    var parameters = [ "param1": "pvalue1", "param2": "pvalue2"]
    var type = RequestType.GET
}

class WeatherStationServiceTests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testBuilderBuilds() {
//        let mockAPIKey = "myAPIKey"
//        let builder = WeatherRequestBuilder(APIKey: mockAPIKey, location: Location(latitude: 51.5102, longitude: 0.0350))
//        let mockAPIRequest = MockAPIRequest()
//        let request = builder.build(mockAPIRequest)
//        
//        XCTAssertEqual(request.httpMethod, mockAPIRequest.type.rawValue)
//        XCTAssertEqual(request.allHTTPHeaderFields, mockAPIRequest.headers)
//        XCTAssertEqual(request.url!.path, "/\(mockAPIKey)/\(mockAPIRequest.path)")
//        XCTAssertEqual(request.url!.query, "param1=pvalue1&param2=pvalue2")
//    }

}
