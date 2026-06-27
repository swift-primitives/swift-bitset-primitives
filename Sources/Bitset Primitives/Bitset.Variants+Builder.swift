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

extension Bitset.Static {
    /// Constructs a fixed-capacity inline bitset from a result-builder closure.
    ///
    /// Wraps the dynamic `Bitset.Builder` per Round-2 Option Y. Member
    /// out-of-range or invalid throws `__BitsetStaticError`.
    public init(
        @Bitset.Builder _ builder: () -> [Int]
    ) throws(__BitsetStaticError) {
        let members = builder()
        self.init()
        for m in members {
            _ = try self.insert(m)
        }
    }
}

extension Bitset.Fixed {
    /// Constructs a heap-allocated fixed-capacity bitset from a result-builder closure.
    ///
    /// Wraps the dynamic `Bitset.Builder`. Capacity at outer init;
    /// out-of-range or overflow throws `__BitsetFixedError`.
    public init(
        capacity: Int,
        @Bitset.Builder _ builder: () -> [Int]
    ) throws(__BitsetFixedError) {
        var fixed = try Bitset.Fixed(capacity: capacity)
        let members = builder()
        for m in members {
            _ = try fixed.insert(m)
        }
        self = fixed
    }
}
