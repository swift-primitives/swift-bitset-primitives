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

extension Bitset.Static {
    /// Nested accessor for set relation operations.
    ///
    /// ```swift
    /// if a.relation.isSubset(of: b) { ... }
    /// if a.relation.isSuperset(of: b) { ... }
    /// if a.relation.isDisjoint(with: b) { ... }
    /// ```
    @inlinable
    public var relation: Relation {
        Relation(storage: storage)
    }
}

// MARK: - Relation Type

extension Bitset.Static {
    /// Namespace for set relation operations.
    public struct Relation: Sendable {
        @usableFromInline
        let storage: InlineArray<wordCount, UInt>

        @usableFromInline
        init(storage: InlineArray<wordCount, UInt>) {
            self.storage = storage
        }
    }
}

// MARK: - Relation Operations

extension Bitset.Static.Relation {
    /// Returns whether this set is a subset of another.
    ///
    /// - Parameter other: The potential superset.
    /// - Returns: `true` if every member in this set is also in `other`.
    @inlinable
    public func isSubset(of other: Bitset.Static<wordCount>) -> Bool {
        for i in 0..<wordCount {
            if (storage[i] & ~other.storage[i]) != 0 {
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
    public func isSuperset(of other: Bitset.Static<wordCount>) -> Bool {
        other.relation.isSubset(of: Bitset.Static<wordCount>(__storage: storage))
    }

    /// Returns whether this set is disjoint from another.
    ///
    /// - Parameter other: The other set.
    /// - Returns: `true` if the sets have no members in common.
    @inlinable
    public func isDisjoint(with other: Bitset.Static<wordCount>) -> Bool {
        for i in 0..<wordCount {
            if (storage[i] & other.storage[i]) != 0 {
                return false
            }
        }
        return true
    }
}
