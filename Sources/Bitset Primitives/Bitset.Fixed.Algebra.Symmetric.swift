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

extension Bitset.Fixed.Algebra {
    /// Namespace for symmetric set operations.
    public struct Symmetric: Sendable {
        @usableFromInline
        let storage: ContiguousArray<UInt>

        @usableFromInline
        let capacity: Int

        @usableFromInline
        init(storage: ContiguousArray<UInt>, capacity: Int) {
            self.storage = storage
            self.capacity = capacity
        }
    }
}

// MARK: - Symmetric Operations

extension Bitset.Fixed.Algebra.Symmetric {
    /// Returns a new set with members in either set, but not both.
    ///
    /// - Precondition: Capacities must match.
    /// - Parameter other: The other set.
    /// - Returns: A new set with members in exactly one of the sets.
    @inlinable
    public func difference(_ other: Bitset.Fixed) -> Bitset.Fixed {
        precondition(capacity == other.capacity, "Capacities must match")
        var resultStorage = storage
        for i in 0..<resultStorage.count {
            resultStorage[i] ^= other.storage[i]
        }
        return Bitset.Fixed(__storage: resultStorage, capacity: capacity)
    }
}
