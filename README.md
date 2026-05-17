# Cursor Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A typed cursor substrate — `Cursor.Span<DomainTag>`, the institute's unified borrowed read-only cursor over `Swift.Span<UInt8>`. The phantom `DomainTag` carries the domain identity (binary stream, text stream, …) while the implementation is shared. Position is typed `Tagged<DomainTag, Ordinal>` per the institute's typed-position discipline.

`Cursor.Span<Byte>` is the substrate for `Binary.Bytes.Input.View`. `Cursor.Span<Text>` is the substrate for `Lexer.Scanner`. Both consumers reuse the same generic primitive via DomainTag parameterization.

---

## Quick Start

```swift
import Cursor_Primitives

private enum Pcap {}  // a custom byte-stream domain

unsafe bytes.withUnsafeBufferPointer { buf in
    let span = unsafe Swift.Span(_unsafeElements: buf)
    var cursor = Cursor.Span<Pcap>(span)

    while let b = cursor.peek() {
        // classify b, dispatch, decide...
        cursor.advance()
    }
}
```

### API surface

| Operation | Signature | Purpose |
|---|---|---|
| `init(_:)` | `(borrowing Span<UInt8>) -> Self` | Construct at position zero, borrowing the source. |
| `position` | `var: Tagged<DomainTag, Ordinal>` | Read current position. |
| `count` | `var: Tagged<DomainTag, Cardinal>` | Bytes remaining from current position. |
| `isAtEnd` | `var: Bool` | True when no bytes remain. |
| `peek()` | `() -> UInt8?` | Byte at current position, nil at end. |
| `peek(at:)` | `(Tagged<DomainTag, Cardinal>) -> UInt8?` | Byte at offset past current. |
| `advance()` | `mutating ()` | Advance by one byte. |
| `advance(by:)` | `mutating (Tagged<DomainTag, Cardinal>)` | Advance by N bytes. |
| `consume()` | `mutating () -> UInt8` | Fused peek-then-advance. |

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

The package is pre-1.0 — until 0.1.0 is tagged, depend on `branch: "main"` rather than `from: "0.1.0"`. Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Four library products at Phase 1 — namespace + variant + umbrella + test support.

| Product | Target | Purpose |
|---------|--------|---------|
| `Cursor Primitives Core` | `Sources/Cursor Primitives Core/` | Namespace `Cursor` + re-exports of `Tagged_Primitives`, `Ordinal_Primitives`, `Cardinal_Primitives`. |
| `Cursor Span Primitives` | `Sources/Cursor Span Primitives/` | `Cursor.Span<DomainTag>` — borrowed read-only cursor over `Swift.Span<UInt8>`. |
| `Cursor Primitives` | `Sources/Cursor Primitives/` | Umbrella re-export of Core + Span variant. Canonical consumer import. |
| `Cursor Primitives Test Support` | `Tests/Support/` | Re-exports the umbrella + `Index Primitives Test Support` for downstream test consumers. |

### Phase 4 expansion (committed follow-on)

Per `swift-institute/Research/cursor-abstractions-l1-ecosystem.md` v1.3.0 (DECISION, 2026-05-17), the Phase 4 follow-on adds:

| Variant | Type | World |
|---|---|---|
| `Cursor.OwnedReader<Storage>` | owned read-only | World 1 |
| `Cursor.OwnedReaderWriter<Storage>` | owned read-write | World 1 |
| `Cursor.Input<Element>` | owned Copyable input | World 3 |

The Three-Worlds type structure is fixed by Swift's type system (Escapable / `~Escapable` and Copyable / `~Copyable` are not generic-parameterizable). Phase 4 centralizes placement; the type structure persists.

Foundation-free at every layer.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26+ | ✅ |
| iOS 26+ | ✅ |
| tvOS 26+ | ✅ |
| watchOS 26+ | ✅ |
| visionOS 26+ | ✅ |
| Linux (Swift 6.3+) | ✅ |
| Windows (Swift 6.3+) | ✅ |
| Embedded Swift | ✅ |

---

## License

Apache License 2.0. See `LICENSE.md`.
