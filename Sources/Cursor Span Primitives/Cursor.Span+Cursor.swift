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

extension Cursor.Span {
    /// The cursor's current position within the borrowed source.
    @inlinable
    public var position: Tagged<DomainTag, Ordinal> { _position }

    /// Number of bytes remaining from the current position to the end.
    @inlinable
    public var count: Tagged<DomainTag, Cardinal> {
        Tagged<DomainTag, Cardinal>(
            _unchecked: Cardinal(UInt(bitPattern: source.count - Int(bitPattern: _position)))
        )
    }

    /// `true` if no bytes remain to read.
    @inlinable
    public var isAtEnd: Bool {
        Int(bitPattern: _position) >= source.count
    }

    /// The byte at the current position, or `nil` if the cursor is at end of input.
    @inlinable
    public func peek() -> UInt8? {
        let p = Int(bitPattern: _position)
        guard p < source.count else { return nil }
        return source[p]
    }

    /// The byte `offset` bytes past the current position, or `nil` if that
    /// position is at or past the end.
    @inlinable
    public func peek(at offset: Tagged<DomainTag, Cardinal>) -> UInt8? {
        let p = Int(bitPattern: _position) &+ Int(bitPattern: offset)
        guard p >= 0 && p < source.count else { return nil }
        return source[p]
    }

    /// Advances the cursor by one byte.
    ///
    /// - Precondition: `!isAtEnd`.
    @inlinable
    @_lifetime(self: copy self)
    public mutating func advance() {
        precondition(Int(bitPattern: _position) < source.count, "advance() past end of input")
        _position += .one
    }

    /// Advances the cursor by `count` bytes.
    @inlinable
    @_lifetime(self: copy self)
    public mutating func advance(by count: Tagged<DomainTag, Cardinal>) {
        _position += count
    }

    /// Reads the byte at the current cursor and advances by one.
    ///
    /// Fused peek-then-advance — callers that have already verified
    /// `!isAtEnd` (e.g., via a preceding ``peek()`` check) avoid the
    /// redundant Optional unwrap that a separate `peek()` + `advance()`
    /// pair pays.
    ///
    /// - Precondition: `!isAtEnd`.
    @inlinable
    @_lifetime(self: copy self)
    public mutating func consume() -> UInt8 {
        let p = Int(bitPattern: _position)
        precondition(p < source.count, "consume() past end of input")
        let b = source[p]
        _position += .one
        return b
    }
}
