import Foundation

/// A decoded snapshot of a raw-representable type: the wire ``rawValue`` is always kept;
/// ``value`` is `nil` when the raw value does not map to a known enum case (or other `RawRepresentable`).
public struct SafeEnum<T>: Hashable, Sendable
where T: RawRepresentable & Hashable & Sendable,
      T.RawValue: Hashable & Sendable {

    /// The enum case (or other `T`) when ``rawValue`` was valid for `T(rawValue:)`; otherwise `nil`.
    public let value: T?

    /// The scalar decoded from JSON (or other format); always present after a successful decode.
    public let rawValue: T.RawValue

    /// Creates a value from a raw representation; ``value`` is `T(rawValue:)` or `nil`.
    @inlinable
    public init(rawValue: T.RawValue) {
        self.rawValue = rawValue
        self.value = T(rawValue: rawValue)
    }

    /// Creates a value from a known `T`; ``rawValue`` is `value.rawValue`.
    @inlinable
    public init(_ value: T) {
        self.value = value
        self.rawValue = value.rawValue
    }

    /// Returns ``value`` when it is non-`nil`; otherwise returns `fallback`.
    @inlinable
    public func unwrap(or fallback: T) -> T {
        value ?? fallback
    }
}

extension SafeEnum: CustomStringConvertible {

    /// String representation of ``rawValue`` (for logging).
    public var description: String {
        String(describing: rawValue)
    }
}

extension SafeEnum: Decodable where T.RawValue: Decodable {

    /// Decodes a single encoded scalar as ``rawValue``, then applies `init(rawValue:)`.
    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(T.RawValue.self)
        self.init(rawValue: rawValue)
    }
}

extension SafeEnum: Encodable where T.RawValue: Encodable {

    /// Encodes ``rawValue`` as a single scalar (same shape as decode).
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension SafeEnum: ExpressibleByUnicodeScalarLiteral where T.RawValue == String {

    @inlinable
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self.init(rawValue: String(value))
    }
}

extension SafeEnum: ExpressibleByExtendedGraphemeClusterLiteral where T.RawValue == String {

    @inlinable
    public init(extendedGraphemeClusterLiteral value: Character) {
        self.init(rawValue: String(value))
    }
}

extension SafeEnum: ExpressibleByStringLiteral where T.RawValue == String {

    /// Interprets the literal as a wire/raw string; ``value`` is `nil` if it does not map to `T`.
    @inlinable
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
