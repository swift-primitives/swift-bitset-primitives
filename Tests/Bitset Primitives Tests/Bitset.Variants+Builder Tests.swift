// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing

@testable import Bitset_Primitives

@Suite("Bitset variants + Builder")
struct BitsetVariantsBuilderTests {
    @Suite struct StaticBitset {}
    @Suite struct FixedBitset {}
}

extension BitsetVariantsBuilderTests.StaticBitset {
    @Test
    func `Static within capacity`() throws {
        let b = try Bitset.Static<2> {
            1
            5
            10
        }
        #expect(b.contains(5))
        #expect(b.count == 3)
    }
}

extension BitsetVariantsBuilderTests.FixedBitset {
    @Test
    func `Fixed within capacity`() throws {
        let b = try Bitset.Fixed(capacity: 16) {
            1
            5
            10
        }
        #expect(b.contains(5))
    }

    @Test
    func `Fixed throws on out-of-range`() {
        do {
            _ = try Bitset.Fixed(capacity: 8) {
                1
                100
            }
            Issue.record("expected throw")
        } catch {
            // expected
        }
    }
}
