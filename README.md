# SafeEnum

Repository: **[github.com/avgx/SafeEnum](https://github.com/avgx/SafeEnum)**

Small Swift package: decode a `RawRepresentable` field without failing the whole payload when the server sends a new or unknown raw value. The wire value is always stored in `rawValue`; use `value` when the raw maps to a known case.

## Why not an optional enum?

`Status?` on a `Codable` model only helps when:

- the field is **missing**, or
- the JSON value is **`null`**

It does **not** help when the field is present with a **string (or other raw) that is not a known case**: synthesized `Codable` for the enum still **throws** on decode.

`SafeEnum<Status>` keeps the **raw payload** (`rawValue`) and sets `value` to `nil` for unknown raws, so the **rest of the document decodes** and you can log or branch on the wire value.

### Use cases

- API / DTO packages shared across apps
- Forward-compatible clients (older binaries, newer server enums)
- Evolving backend contracts without coordinated releases
- Telemetry when the server sends enum values your build does not know yet

### Example logging

```swift
if dto.status.value == nil {
    logger.warning("Unknown status: \(dto.status.rawValue)")
}
```

(`dto` is your decoded model, e.g. `User`; use your app’s logging API instead of `logger` if needed.)

## Add the package (SPM)

In `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/avgx/SafeEnum", from: "1.0.0"),
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

// When `T.RawValue` is `String`, you can use a string literal:
let status: SafeEnum<Status> = "active"

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

// Default for app logic / UI when the server sends an unknown raw:
let resolved = u2.status.unwrap(or: .inactive)
```

Encoding writes the same scalar as `rawValue`:

```swift
let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys]
let data = try encoder.encode(User(status: SafeEnum(.inactive)))
// {"status":"inactive"}
```

## License

[MIT](https://github.com/avgx/SafeEnum/blob/main/LICENSE). Full text is in the [`LICENSE`](LICENSE) file in this repository.
