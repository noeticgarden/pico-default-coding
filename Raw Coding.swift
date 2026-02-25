
/// Marks a type as writing a raw value in its own place when encoded.
///
/// If a type conforms to this protocol and `RawRepresentable`, it will encode its `rawValue` in its own stead when encoded.
public protocol RawEncodable: Encodable {}

extension RawEncodable where Self: RawRepresentable, RawValue: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// Marks a type as reading a raw value and wrapping it own place when encoded.
///
/// If a type conforms to this protocol and `RawRepresentable`, it will decode its `rawValue` from the current decoder.
public protocol RawDecodable: Decodable {}

/// Thrown if trying to decode a type conforming to ``RawDecodable``, when the value that it is trying to decode in its place cannot be used as the raw value for the type.
public struct RawDecodableCannotRepresentValue: Error {
    /// The name of the type of the value that could not be decoded.
    public let type: String
}

extension RawDecodable where Self: RawRepresentable, RawValue: Decodable {
    public init(from decoder: any Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(RawValue.self)
        guard let me = Self.init(rawValue: rawValue) else {
            let myType = String(reflecting: Self.self)
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "This raw value cannot be represented as '\(myType)'.", underlyingError: RawDecodableCannotRepresentValue(type: String(reflecting: Self.self))))
        }
        
        self = me
    }
}

/// Marks a type as encoding and decoding a raw value in its place when encoding or decoding itself.
///
/// If a type conforms to this protocol set and `RawRepresentable`, it will encode and decode its `rawValue` from the current decoder.
public typealias RawCodable = RawEncodable & RawDecodable
