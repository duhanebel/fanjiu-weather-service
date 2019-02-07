import Foundation

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
