import XCTest

import WeatherStationService

class BinaryCoderTests: XCTestCase {
    func testPrimitiveEncoding() throws {
        let s = Primitives(ui8: 1, ui16: 2, f: 3.6, d: 4.5)
        let data = try BinaryEncoder.encode(s)
        XCTAssertEqual(data, [
            1,
            2, 0,
            36, 0,
            45, 0
        ])
    }
    
    func testChecksumGeneration() {
        struct SumTest: BinaryCodable {
            let i: UInt16 = 1
            let u: UInt16 = 2
            let sum: Checksum = Checksum()
        }
        
        let data = SumTest()
        let generatedData: [UInt8] = [
            1, 0,
            2, 0,
            3, 0
        ]

        XCTAssertEqual(try BinaryEncoder.encode(data), generatedData)
    }
   
    func testPrimitiveDecoding() throws {
        let data: [UInt8] = [
            1,
            2, 0,
            36, 0,
            45, 0
        ]
        let s = try BinaryDecoder.decode(Primitives.self, data: data)
        XCTAssertEqual(s.ui8, 1)
        XCTAssertEqual(s.ui16, 2)
        XCTAssertEqual(s.f, 3.6)
        XCTAssertEqual(s.d, 4.5)
    }
}

private func AssertEqual<T>(_ lhs: T, _ rhs: T, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(String(describing: lhs), String(describing: rhs), file: file, line: line)
}


struct Primitives: BinaryCodable {
    var ui8: UInt8
    var ui16: UInt16
    var f: Float
    var d: Double
}

