# SafeEnum

Repository: **[github.com/avgx/SafeEnum](https://github.com/avgx/SafeEnum)**

Small Swift package: decode a `RawRepresentable` field without failing the whole payload when the server sends a new or unknown raw value. The wire value is always stored in `rawValue`; use `value` when the raw maps to a known case.

## Add the package (SPM)

In Xcode: **File → Add Package Dependencies…** → enter  
`https://github.com/avgx/SafeEnum`  
and pick the **`main`** branch (or a version tag once you publish releases).

In `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/avgx/SafeEnum", branch: "main"),
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "SafeEnum", package: "SafeEnum"),
    ]),
]
```

After the first semver tag (for example `1.0.0`), you can pin with:

```swift
.package(url: "https://github.com/avgx/SafeEnum", from: "1.0.0"),
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

[MIT](https://github.com/avgx/SafeEnum/blob/main/LICENSE). Full text is in the [`LICENSE`](LICENSE) file in this repository.
