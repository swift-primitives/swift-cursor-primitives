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

public import Ordinal_Primitives
public import Ownership_Borrow_Primitives
public import Tagged_Primitives

// SAFETY: Safe by construction — backing storage uses only stdlib safe
// SAFETY: types; `@safe` documents that this type performs no unsafe
// SAFETY: operations.
//
// `@frozen` exposes the two-field layout (storage + _position) to the
// optimizer for cross-module specialization on hot paths
// (Cursor<Text>.peek() in lexer scanners; Cursor<Byte>.consume() in
// parsers). Per typed-index-specialization-audit v1.0.0 — the canonical
// `Cursor<DomainTag>` layout is permanent; consumers do not introspect
// it. `@safe` documents the type performs no unsafe operations.

/// A position-tracking cursor over a borrowed-bytes domain.
///
/// `Cursor` is the institute's unified borrowed-bytes cursor primitive — a
/// generic struct parameterized over a single `DomainTag` whose conformance
/// to `Ownership.Borrow.\`Protocol\`` carries both:
///
/// - The phantom domain identity (`Byte`, `Text`, or a custom byte-stream
///   domain) — used to type positions as `Tagged` over the domain and an
///   `Ordinal`, and counts as `Tagged` over the domain and a `Cardinal`;
/// - The storage shape via the protocol's associated type — `DomainTag.Borrowed`
///   resolves to a `~Copyable, ~Escapable` borrow-view (canonically bare
///   `Swift.Span<Byte>`).
///
/// The single-generic shape supersedes the prior two-generic
/// `Cursor<Storage, PositionTag>` (2026-05-18 first-reshape). Domain and
/// storage are no longer independent generic parameters — the domain's
/// `Ownership.Borrow.\`Protocol\`` conformance binds them. `Cursor<Byte>`
/// and `Cursor<Text>` are the canonical call-site shapes.
///
/// ## Lifetime
///
/// `~Copyable & ~Escapable` — inherited unconditionally from the storage's
/// own `~Copyable & ~Escapable` profile (`DomainTag.Borrowed` is constrained
/// to `~Copyable, ~Escapable` by `Ownership.Borrow.\`Protocol\``'s
/// associated-type declaration). The cursor cannot be duplicated and cannot
/// outlive the source storage; compiler-enforced via the storage's own
/// `@_lifetime(borrow …)` propagation through `init(_:)`.
///
/// ## Design rationale
///
/// Per `swift-institute/Research/cursor-shape-a-vs-three-worlds.md` v1.2.0
/// (single-generic refinement of the v1.1.0 DECISION 2026-05-18).
/// Leverages `Ownership.Borrow.\`Protocol\`` from `swift-ownership-primitives`
/// and the Case-B conformers `Byte` and `Text` (both resolving `Borrowed` to
/// `Swift.Span<Byte>` after the W3 `.Borrowed` prune) per the
/// `ownership-borrow-protocol-unification.md` v1.0.0 DECISION framework.
///
/// ## Phase 4 scope note
///
/// The protocol-bound shape is scoped to borrowed-Span cursors (W2). Owned
/// `Storage.Contiguous.\`Protocol\`` storage (W1) and owned `[UInt8]` (W3)
/// don't fit `Ownership.Borrow.\`Protocol\``'s borrowed-view contract;
/// Phase 4 expansion requires either a sibling owned-cursor type or a more
/// general protocol bound. Deferred per the v1.2.0 doc.
@frozen
@safe
public struct Cursor<
    DomainTag: Ownership.Borrow.`Protocol` & ~Copyable
>: ~Copyable, ~Escapable {
    /// The borrowed storage being read.
    ///
    /// Set once at construction; immutable thereafter. The `let` declaration
    /// rules out arbitrary external reassignment.
    public let storage: DomainTag.Borrowed

    // swiftlint:disable no_tag_suffix_phantom
    // reason: `DomainTag` is the public generic-parameter name of `Cursor`,
    // referenced across sibling packages (`extension Cursor where
    // DomainTag == Byte` in swift-byte-parser-primitives; `Cursor<Text>` in
    // swift-lexer-primitives). Renaming to the bare-concept form
    // ([API-NAME-010]) is a cross-package breaking change, out of scope for
    // mechanical release-prep; deferred to a coordinated rename.

    /// The cursor's mutable position offset within `storage`.
    ///
    /// The underscore prefix marks this as an implementation detail.
    /// `@frozen` requires the storage layout to be public, and Swift's
    /// `@inlinable` cross-package rules require any setter referenced from
    /// inlinable extensions in sibling packages to be public — so the
    /// setter cannot be narrowed further while preserving hot-path inlining.
    /// External consumers SHOULD route mutation through the operation
    /// methods defined in sibling packages (advance, consume, seek) rather
    /// than assigning directly.
    public var _position: Tagged<DomainTag, Ordinal>

    /// Creates a cursor at position zero from a borrowed-storage instance.
    ///
    /// The cursor consumes the storage and binds its lifetime to the
    /// storage's own lifetime scope (e.g., a `Swift.Span<Byte>`'s borrow
    /// lifetime propagates through this init).
    @inlinable
    @_lifetime(copy storage)
    public init(_ storage: consuming DomainTag.Borrowed) {
        self.storage = storage
        self._position = Tagged<DomainTag, Ordinal>(_unchecked: Ordinal(UInt(0)))
    }
    // swiftlint:enable no_tag_suffix_phantom
}
