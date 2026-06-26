# Cursor Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A single-generic borrowed-bytes cursor — `Cursor<DomainTag>` reads a borrowed byte source while tracking a compile-time-typed position, with zero platform dependencies.

---

## Quick Start

`Cursor<DomainTag>` is parameterized over one tag whose ``Ownership.Borrow.`Protocol` `` conformance supplies both the phantom domain identity (used to type the position as `Tagged<DomainTag, Ordinal>`) and the borrowed-storage shape (`DomainTag.Borrowed`). A domain whose `Borrowed` is `Swift.Span<Byte>` — like `Byte`, or any custom byte-stream tag — yields a cursor over a bare span.

```swift
import Cursor_Primitives
import Byte_Primitives           // Byte conforms to Ownership.Borrow.`Protocol`

// A custom byte-stream domain reuses the same generic primitive; its
// borrowed projection is a bare Swift.Span<Byte>, matching Byte and Text.
private enum Pcap {}
extension Pcap: Ownership.Borrow.`Protocol` {
    typealias Borrowed = Swift.Span<Byte>
}

func startOffset(of span: consuming Swift.Span<Byte>) -> Tagged<Pcap, Ordinal> {
    // Construct at position zero; the cursor's lifetime is bound to the span's.
    let cursor = Cursor<Pcap>(span)
    return cursor._position          // typed Tagged<Pcap, Ordinal>, value 0
}
```

The cursor is `~Copyable & ~Escapable`: it cannot be duplicated and cannot outlive the borrowed source. `init(_:)` consumes a `DomainTag.Borrowed` and binds the cursor to that storage's lifetime scope. Position-advancing operations (peek, advance, consume, seek) are added by the byte-domain consumer packages that build on this substrate.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-cursor-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Cursor Primitives", package: "swift-cursor-primitives"),
    ]
)
```

The package is pre-1.0; until 0.1.0 is tagged, depend on `branch: "main"` rather than `from: "0.1.0"`. Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Three library products, composed over lower-tier primitives.

| Product | Target | Purpose |
|---------|--------|---------|
| `Cursor Primitive` | `Sources/Cursor Primitive/` | The `Cursor<DomainTag>` struct, plus re-exports of `Ordinal_Primitives`, `Cardinal_Primitives`, `Ownership_Borrow_Primitives`, and `Tagged_Primitives`. |
| `Cursor Primitives` | `Sources/Cursor Primitives/` | Umbrella re-export of `Cursor Primitive`. The canonical consumer import. |
| `Cursor Primitives Test Support` | `Tests/Support/` | Re-exports the umbrella and `Index Primitives Test Support` for downstream test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
