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

extension Bitset.Small {
    /// Nested accessor for set relation operations.
    ///
    /// ```swift
    /// if a.relation.isSubset(of: b) { ... }
    /// if a.relation.isSuperset(of: b) { ... }
    /// if a.relation.isDisjoint(with: b) { ... }
    /// ```
    @inlinable
    public var relation: Relation {
        Relation(
            inlineStorage: inlineStorage,
            heapStorage: heapStorage,
            storedCapacity: storedCapacity
        )
    }
}

// MARK: - Relation Type

extension Bitset.Small {
    /// Namespace for set relation operations.
    public struct Relation: Sendable {
        @usableFromInline
        let inlineStorage: InlineArray<inlineWordCount, UInt>

        @usableFromInline
        let heapStorage: ContiguousArray<UInt>?

        @usableFromInline
        let storedCapacity: Int

        @usableFromInline
        init(
            inlineStorage: InlineArray<inlineWordCount, UInt>,
            heapStorage: ContiguousArray<UInt>?,
            storedCapacity: Int
        ) {
            self.inlineStorage = inlineStorage
            self.heapStorage = heapStorage
            self.storedCapacity = storedCapacity
        }

        @usableFromInline
        var wordCount: Int {
            if let heapStorage = heapStorage {
                return heapStorage.count
            } else {
                return inlineWordCount
            }
        }

        @usableFromInline
        func word(at index: Int) -> UInt {
            if let heapStorage = heapStorage {
                return heapStorage[index]
            } else {
                return inlineStorage[index]
            }
        }
    }
}

// MARK: - Relation Operations

extension Bitset.Small.Relation {
    /// Returns whether this set is a subset of another.
    ///
    /// - Parameter other: The potential superset.
    /// - Returns: `true` if every member in this set is also in `other`.
    @inlinable
    public func isSubset(of other: Bitset.Small<inlineWordCount>) -> Bool {
        let selfWordCount = wordCount
        let otherWordCount = other.wordCount

        for i in 0..<selfWordCount {
            let selfWord = word(at: i)
            let otherWord: UInt
            if i < otherWordCount {
                if let heapStorage = other.heapStorage {
                    otherWord = heapStorage[i]
                } else {
                    otherWord = other.inlineStorage[i]
                }
            } else {
                otherWord = 0
            }

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
    public func isSuperset(of other: Bitset.Small<inlineWordCount>) -> Bool {
        other.relation.isSubset(of: Bitset.Small<inlineWordCount>(
            __inlineStorage: inlineStorage,
            heapStorage: heapStorage,
            storedCapacity: storedCapacity
        ))
    }

    /// Returns whether this set is disjoint from another.
    ///
    /// - Parameter other: The other set.
    /// - Returns: `true` if the sets have no members in common.
    @inlinable
    public func isDisjoint(with other: Bitset.Small<inlineWordCount>) -> Bool {
        let minWordCount = Swift.min(wordCount, other.wordCount)

        for i in 0..<minWordCount {
            let selfWord = word(at: i)
            let otherWord: UInt
            if let heapStorage = other.heapStorage {
                otherWord = heapStorage[i]
            } else {
                otherWord = other.inlineStorage[i]
            }

            if (selfWord & otherWord) != 0 {
                return false
            }
        }
        return true
    }
}
