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

/// Top-level namespace for cursor primitives.
///
/// A *cursor* is the institute's substrate primitive for "position-within-storage"
/// abstractions — types that combine contiguous byte storage with an in-storage
/// position and a peek/advance/consume API. Every parser, lexer, serializer, and
/// binary-format reader/writer in the institute composes from a cursor at its
/// base layer.
///
/// At Phase 1 the namespace hosts a single variant:
///
/// - ``Cursor/Span`` — borrowed read-only Span-cursor parameterized over a
///   phantom `DomainTag`; the unified substrate for `Binary.Bytes.Input.View`
///   (`DomainTag = Byte`) and `Lexer.Scanner` (`DomainTag = Text`).
///
/// Phase 4 of the cursor-abstractions arc (see
/// `swift-institute/Research/cursor-abstractions-l1-ecosystem.md`) extends the
/// namespace with owned reader / reader-writer / Copyable-input variants — same
/// type structure, same package home, type-system attributes differ per world.
public enum Cursor {}
