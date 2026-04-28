import Foundation
import Testing
@testable import SafeEnum

private enum Status: String, Codable, Hashable, Sendable {
    case active, inactive
}

private struct Payload: Codable {
    var state: SafeEnum<Status>
}

@Test func decodeKnownRawMapsToValue() throws {
    let json = #"{"state":"active"}"#.data(using: .utf8)!
    let payload = try JSONDecoder().decode(Payload.self, from: json)
    #expect(payload.state.value == .active)
    #expect(payload.state.rawValue == "active")
}

@Test func decodeUnknownRawPreservesRawValueNilValue() throws {
    let json = #"{"state":"weird_new_case"}"#.data(using: .utf8)!
    let payload = try JSONDecoder().decode(Payload.self, from: json)
    #expect(payload.state.value == nil)
    #expect(payload.state.rawValue == "weird_new_case")
}

@Test func roundTripEncodeDecode() throws {
    let original = Payload(state: SafeEnum(.inactive))
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(Payload.self, from: data)
    #expect(decoded.state.value == .inactive)
    #expect(decoded.state.rawValue == "inactive")
}

@Test func equatableSameRawValue() {
    let a = SafeEnum<Status>(rawValue: "active")
    let b = SafeEnum<Status>(rawValue: "active")
    #expect(a == b)
    #expect(Set([a, b]).count == 1)
}

@Test func expressibleByStringLiteral() {
    let status: SafeEnum<Status> = "active"
    #expect(status.value == .active)
    #expect(status.rawValue == "active")

    let unknown: SafeEnum<Status> = "nope"
    #expect(unknown.value == nil)
    #expect(unknown.rawValue == "nope")
}
