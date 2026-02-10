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

// MARK: - Relation Accessor

extension Bitset {
    /// Nested accessor for set relation operations.
    ///
    /// ```swift
    /// if a.relation.isSubset(of: b) { ... }
    /// if a.relation.isSuperset(of: b) { ... }
    /// if a.relation.isDisjoint(with: b) { ... }
    /// ```
    @inlinable
    public var relation: Relation {
        Relation(storage: storage, capacity: storedCapacity)
    }
}

// MARK: - Relation Type

extension Bitset {
    /// Namespace for set relation operations.
    public struct Relation: Sendable {
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

// MARK: - Relation Operations

extension Bitset.Relation {
    /// Returns whether this set is a subset of another.
    ///
    /// - Parameter other: The potential superset.
    /// - Returns: `true` if every member in this set is also in `other`.
    @inlinable
    public func isSubset(of other: Bitset) -> Bool {
        for i in 0..<storage.count {
            let selfWord = storage[i]
            let otherWord = i < other.storage.count ? other.storage[i] : 0
            if (selfWord & ~otherWord) != 0 {
                return false
            }
        }
        return true
    }

    /// Returns whether this set is a superset of another.
    ///
    /// - Parameter other: The potential subset.
    /// - Returns: `true` if every member in `other` is also in this set.
    @inlinable
    public func isSuperset(of other: Bitset) -> Bool {
        other.relation.isSubset(of: Bitset(__storage: storage, capacity: capacity))
    }

    /// Returns whether this set is disjoint from another.
    ///
    /// - Parameter other: The other set.
    /// - Returns: `true` if the sets have no members in common.
    @inlinable
    public func isDisjoint(with other: Bitset) -> Bool {
        let minWords = Swift.min(storage.count, other.storage.count)
        for i in 0..<minWords {
            if (storage[i] & other.storage[i]) != 0 {
                return false
            }
        }
        return true
    }
}
