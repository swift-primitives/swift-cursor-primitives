// swift-linter-tools-version: 0.1
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

// Standard primitives-tier linter configuration. No brand-owner carve-outs:
// swift-cursor-primitives owns the `Cursor` namespace plus `Cursor.Span<DomainTag>`
// — a generic struct over a phantom tag, not a value-form brand wrapping a
// stdlib carrier. `[API-BRAND-001]` exclusions therefore do not apply.

import Linter
import Linter_Primitives_Rules

Lint.run(dependencies: [
    .package(
        path: "../swift-primitives-linter-rules",
        products: ["Linter Primitives Rules"]
    ),
]) {
    Lint.Rule.Bundle.primitives
}
