import Foundation

//extension Array: BinaryCodable where Element : BinaryCodable {
//    public func binaryEncode(to encoder: BinaryEncoder) throws {
//
//        try encoder.encode(self.count)
//        for element in self {
//            try element.encode(to: encoder)
//        }
//    }
//
//    public init(fromBinary decoder: BinaryDecoder) throws {
//        let binaryElement = Element.self
//
//        let count = try decoder.decode(Int.self)
//        self.init()
//        self.reserveCapacity(count)
//        for _ in 0 ..< count {
//            let decoded = try binaryElement.init(from: decoder)
//            self.append(decoded)
//        }
//    }
//}

extension FixedWidthInteger where Self: BinaryEncodable {
    public func binaryEncode(to encoder: BinaryEncoder) {
        encoder.appendBytes(of: self.littleEndian)
    }
}

extension FixedWidthInteger where Self: BinaryDecodable {
    public init(fromBinary binaryDecoder: BinaryDecoder) throws {
        var v = Self.init()
        try binaryDecoder.read(into: &v)
        self.init(littleEndian: v)
    }
}

extension UInt8: BinaryCodable {}
extension UInt16: BinaryCodable {}
extension UInt32: BinaryCodable {}
