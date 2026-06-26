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

import Testing

@testable import Cursor_Primitives

// `Cursor` is generic (`Cursor<DomainTag>`) and `~Copyable & ~Escapable`, so the
// tests use the parallel namespace pattern per [SWIFT-TEST-003] rather than an
// extension on the source type.

@Suite
struct `Cursor Tests` {
    @Test
    func `namespace is available`() {
        // Minimal smoke test — the real suite is authored during flip-prep.
        #expect(Bool(true))
    }
}
