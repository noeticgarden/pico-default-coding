
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A type that denotes a 'top-level' encoder — a type that an end client interacts with to encode a value into `Data`.
public protocol TopLevelEncoder {
    func encode(_ encodable: some Encodable) throws -> Data
}
/// A type that denotes a 'top-level' decoder — a type that an end client interacts with to decode a value from `Data`.
public protocol TopLevelDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONEncoder: TopLevelEncoder {}
extension JSONDecoder: TopLevelDecoder {}

/**
 A protocol that associates a type with a default ``TopLevelDecoder``, specifying the format it would normally prefer to be loaded from.
 */
public protocol DefaultDecodable {
    /// The type of the decoder that is used by default for this type.
    associatedtype DefaultDecoder: TopLevelDecoder = JSONDecoder
    /// Creates an instance of the preferred decoder for this type.
    static func makeDecoderInstance() -> DefaultDecoder
    
    /// Decodes an instance of this type from the specified file `URL`, using the associated default decoder and editing it before using it for decoding.
    init(contentsOf url: URL, editingDecoder editor: ((inout DefaultDecoder) -> Void)) throws
    /// Decodes an instance of this type from the specified file `URL`, using the associated default decoder.
    init(contentsOf url: URL) throws
    
    /// Decodes an instance of this type from the specified `Data`, using the associated default decoder and editing it before using it for decoding.
    init(contentsOf data: Data, editingDecoder editor: ((inout DefaultDecoder) -> Void)) throws
    /// Decodes an instance of this type from the specified `Data`, using the associated default decoder.
    init(contentsOf data: Data) throws
}

/**
 A protocol that associates a type with a default ``TopLevelEncoder``, specifying the format it would normally prefer to be written as.
 */
public protocol DefaultEncodable {
    /// The type of the encoder that is used by default for this type.
    associatedtype DefaultEncoder: TopLevelEncoder = JSONEncoder
    /// Creates an instance of the preferred encoder for this type.
    static func makeEncoderInstance() -> DefaultEncoder
    /// Encodes an instance of this type, using the associated default decoder and editing it before using it for decoding.
    func encoded(editingEncoder editor: ((inout DefaultEncoder) -> Void)) throws -> Data
    /// Encodes an instance of this type, using the associated default decoder.
    func encoded() throws -> Data
}

/// A protocol set that associates a type with a default format for encoding or decoding it.
public typealias DefaultCodable = DefaultEncodable & DefaultDecodable

extension DefaultDecodable {
    public init(contentsOf url: URL) throws {
        try self.init(contentsOf: url, editingDecoder: { _ in })
    }
    
    public init(contentsOf data: Data) throws {
        try self.init(contentsOf: data, editingDecoder: { _ in })
    }
    
    public init(contentsOf url: URL, editingDecoder editor: ((inout DefaultDecoder) -> Void)) throws {
        try self.init(contentsOf: Data(contentsOf: url), editingDecoder: editor)
    }
}

extension DefaultEncodable {
    public func encoded() throws -> Data {
        try encoded(editingEncoder: { _ in })
    }
}

extension DefaultDecodable where Self: Decodable {
    public init(contentsOf data: Data, editingDecoder editor: ((inout DefaultDecoder) -> Void)) throws {
        self = try Self.makeDecoderInstance().decode(Self.self, from: data)
    }
}

extension DefaultDecodable where DefaultDecoder == JSONDecoder {
    public static func makeDecoderInstance() -> JSONDecoder {
        makeDefaultDecoderInstance()
    }
    
    /// Creates an instance of the decoder that is used by default for conformers to ``DefaultDecodable``.
    ///
    /// By default, a `JSONDecoder` is used as the default decoder. You can modify the behavior of the decoder by invoking this method in your own override of ``makeDecoderInstance()->JSONDecoder``, or create a specific override of ``makeDecoderInstance()->DefaultDecoder`` to specify a different decoder type.
    public static func makeDefaultDecoderInstance() -> JSONDecoder {
        .init()
    }
}

extension DefaultEncodable where Self: Encodable {
    public func encoded(editingEncoder editor: ((inout DefaultEncoder) -> Void)) throws -> Data {
        var encoder = Self.makeEncoderInstance()
        editor(&encoder)
        
        return try encoder.encode(self)
    }
}

extension DefaultEncodable where DefaultEncoder == JSONEncoder {
    public static func makeEncoderInstance() -> JSONEncoder {
        makeDefaultEncoderInstance()
    }
    
    /// Creates an instance of the encoder that is used by default for conformers to ``DefaultEncodable``.
    ///
    /// By default, a `JSONEncoder` with specific options is used as the default encoder. You can modify the behavior of the encoder by invoking this method in your own override of ``makeEncoderInstance()->JSONEncoder``, or create a specific override of ``makeEncoderInstance()->DefaultEncoder`` to specify a different decoder type.
    public static func makeDefaultEncoderInstance() -> JSONEncoder {
        let encoder = JSONEncoder()
        var options: JSONEncoder.OutputFormatting = [JSONEncoder.OutputFormatting.prettyPrinted, .sortedKeys]
        
        if #available(macOS 10.15, iOS 13, tvOS 14, watchOS 6, visionOS 1,  *) {
            options.insert(.withoutEscapingSlashes)
        }
        
        encoder.outputFormatting = options
        
        return encoder
    }
}
