// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-cursor-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-cursor-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Cursor_Primitives_Core

extension Cursor {
    /// A borrowed read-only cursor over a `Swift.Span<UInt8>`, phantom-typed by
    /// the domain whose stream is being read.
    ///
    /// `Cursor.Span` is the institute's unified substrate for borrowed
    /// byte-level cursors. The position type is `Tagged<DomainTag, Ordinal>`,
    /// so `Cursor.Span<Byte>` carries `Index<Byte>` positions for binary
    /// streams and `Cursor.Span<Text>` carries `Text.Position` positions for
    /// text streams. The implementation is generic; the phantom-tag carries the
    /// domain identity without inflating the substrate code.
    ///
    /// ## Lifetime
    ///
    /// `~Copyable & ~Escapable`. The cursor borrows its source `Span<UInt8>`
    /// and cannot outlive it. The relationship is compiler-enforced via
    /// `@_lifetime(borrow source)` on the initializer.
    ///
    /// ## Invariants
    ///
    /// - `0 ≤ position ≤ source.count`
    /// - `count == source.count - position`
    /// - `isAtEnd ⇔ position == source.count`
    ///
    /// ## NOT Sendable
    ///
    /// Borrowed views must not cross task boundaries. For cross-task transfer
    /// use an owned cursor — the unified owned-cursor cluster lands in this
    /// package as part of the Phase 4 follow-on per
    /// `swift-institute/Research/cursor-abstractions-l1-ecosystem.md`.
    // SAFETY: Safe by construction — backing storage uses only stdlib
    // SAFETY: safe types; `@safe` documents that this type performs no
    // SAFETY: unsafe operations.
    @safe
    public struct Span<DomainTag: ~Copyable & ~Escapable>: ~Copyable, ~Escapable {
        @usableFromInline
        internal let source: Swift.Span<UInt8>

        @usableFromInline
        internal var _position: Tagged<DomainTag, Ordinal>

        /// Creates a cursor at position zero over the given source span.
        @inlinable
        @_lifetime(borrow source)
        public init(_ source: borrowing Swift.Span<UInt8>) {
            self.source = copy source
            self._position = Tagged<DomainTag, Ordinal>(_unchecked: Ordinal(UInt(0)))
        }
    }
}
