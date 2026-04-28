# SafeEnum

Small Swift package: decode a `RawRepresentable` field without failing the whole payload when the server sends a new or unknown raw value. The wire value is always stored in `rawValue`; use `value` when the raw maps to a known case.

## Add the package (SPM)

In Xcode: **File → Add Package Dependencies…** and point to this repository or a local checkout path.

In `Package.swift`:

```swift
dependencies: [
    .package(path: "../SafeEnum") // or .package(url: "…", from: "1.0.0")
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "SafeEnum", package: "SafeEnum"),
    ]),
]
```

## Usage

```swift
import SafeEnum

enum Status: String, Codable, Hashable, Sendable {
    case active, inactive
}

struct User: Codable {
    var status: SafeEnum<Status>
}

let decoder = JSONDecoder()

// Known case
let u1 = try decoder.decode(User.self, from: #"{"status":"active"}"#.data(using: .utf8)!)
// u1.status.value == .active
// u1.status.rawValue == "active"

// Unknown case — decode still succeeds
let u2 = try decoder.decode(User.self, from: #"{"status":"legacy_or_typo"}"#.data(using: .utf8)!)
// u2.status.value == nil
// u2.status.rawValue == "legacy_or_typo"  // log or migrate later
```

Encoding writes the same scalar as `rawValue`:

```swift
let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys]
let data = try encoder.encode(User(status: SafeEnum(.inactive)))
// {"status":"inactive"}
```

## Requirements

Swift 6.2+ (see `Package.swift`). Platforms: iOS 15+, macOS 13+, etc.

## License

Add your license here if you publish the package.
