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

// MARK: - Test Suite Structure

@Suite("Bitset.Builder")
struct BitsetBuilderTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite struct StaticMethods {}
}

// MARK: - Helpers

extension BitsetBuilderTests {
    fileprivate static func collected(_ bitset: Bitset) -> [Int] {
        var result: [Int] = []
        for i in 0..<bitset.capacity {
            if bitset.contains(i) {
                result.append(i)
            }
        }
        return result
    }
}

// MARK: - Unit Tests

extension BitsetBuilderTests.Unit {

    @Test
    func `Single member`() throws {
        let bitset = try Bitset { 5 }
        #expect(bitset.contains(5))
        #expect(bitset.count == 1)
    }

    @Test
    func `Multiple members`() throws {
        let bitset = try Bitset {
            1
            5
            10
        }
        #expect(BitsetBuilderTests.collected(bitset) == [1, 5, 10])
    }

    @Test
    func `Duplicates collapse`() throws {
        let bitset = try Bitset {
            1
            5
            1
            5
            5
        }
        #expect(BitsetBuilderTests.collected(bitset) == [1, 5])
        #expect(bitset.count == 2)
    }

    @Test
    func `Optional member - some`() throws {
        let value: Int? = 42
        let bitset = try Bitset { value }
        #expect(bitset.contains(42))
    }

    @Test
    func `Optional member - none`() throws {
        let value: Int? = nil
        let bitset = try Bitset { value }
        #expect(bitset.isEmpty)
    }

    @Test
    func `Mixed members and optionals`() throws {
        let some: Int? = 7
        let none: Int? = nil
        let bitset = try Bitset {
            1
            some
            none
            10
        }
        #expect(BitsetBuilderTests.collected(bitset) == [1, 7, 10])
    }

    @Test
    func `Empty block`() throws {
        let bitset = try Bitset {}
        #expect(bitset.isEmpty)
    }

    @Test
    func `Zero is valid member`() throws {
        let bitset = try Bitset { 0 }
        #expect(bitset.contains(0))
    }
}

// MARK: - Control Flow

extension BitsetBuilderTests.Unit {

    @Test
    func `Conditional include`() throws {
        let include = true
        let bitset = try Bitset {
            1
            if include {
                5
            }
            10
        }
        #expect(BitsetBuilderTests.collected(bitset) == [1, 5, 10])
    }

    @Test
    func `Conditional exclude`() throws {
        let include = false
        let bitset = try Bitset {
            1
            if include {
                5
            }
            10
        }
        #expect(BitsetBuilderTests.collected(bitset) == [1, 10])
    }

    @Test
    func `For loop produces sequence of members`() throws {
        let bitset = try Bitset {
            for i in 0..<5 {
                i * 2
            }
        }
        #expect(BitsetBuilderTests.collected(bitset) == [0, 2, 4, 6, 8])
    }

    @Test
    func `For loop with stride`() throws {
        let bitset = try Bitset {
            for i in stride(from: 0, to: 10, by: 3) {
                i
            }
        }
        #expect(BitsetBuilderTests.collected(bitset) == [0, 3, 6, 9])
    }
}

// MARK: - Edge Cases

extension BitsetBuilderTests.EdgeCase {

    @Test
    func `Wide member range`() throws {
        let bitset = try Bitset {
            0
            64
            128
            256
        }
        #expect(BitsetBuilderTests.collected(bitset) == [0, 64, 128, 256])
        #expect(bitset.count == 4)
    }

    @Test
    func `Many sequential members`() throws {
        let bitset = try Bitset {
            for i in 0..<100 {
                i
            }
        }
        #expect(bitset.count == 100)
    }

    @Test
    func `Deeply nested conditionals`() throws {
        let a = true
        let b = false
        let c = true
        let bitset = try Bitset {
            0
            if a {
                1
                if b {
                    2
                } else {
                    3
                    if c {
                        4
                    }
                }
            }
            99
        }
        #expect(BitsetBuilderTests.collected(bitset) == [0, 1, 3, 4, 99])
    }
}

// MARK: - Integration

extension BitsetBuilderTests.Integration {

    @Test
    func `Builder result accepts further inserts`() throws {
        var bitset = try Bitset {
            1
            2
        }
        try bitset.insert(3)
        #expect(BitsetBuilderTests.collected(bitset) == [1, 2, 3])
    }

    @Test
    func `Builder result supports membership testing`() throws {
        let primes = try Bitset {
            2
            3
            5
            7
            11
        }
        #expect(primes.contains(7))
        #expect(!primes.contains(8))
    }
}

// MARK: - Static Method Tests

extension BitsetBuilderTests.StaticMethods {

    @Test
    func `buildExpression single member`() {
        let result = Bitset.Builder.buildExpression(42)
        #expect(result == [42])
    }

    @Test
    func `buildExpression array`() {
        let result = Bitset.Builder.buildExpression([1, 2, 3])
        #expect(result == [1, 2, 3])
    }

    @Test
    func `buildPartialBlock accumulated and next`() {
        let result = Bitset.Builder.buildPartialBlock(
            accumulated: [1, 2],
            next: [3, 4]
        )
        #expect(result == [1, 2, 3, 4])
    }

    @Test
    func `buildArray flattens components`() {
        let result = Bitset.Builder.buildArray([[1, 2], [3, 4], [5]])
        #expect(result == [1, 2, 3, 4, 5])
    }
}
