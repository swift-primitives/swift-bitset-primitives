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

public import Iterator_Protocol

// MARK: - Sequence

extension Bitset: Swift.Sequence {
    /// An iterator over the members of a bitset.
    ///
    /// Members are yielded in ascending order using Wegner/Kernighan
    /// sparse iteration (`word &= word &- 1`), giving O(popcount)
    /// complexity rather than O(universe size).
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol, Sendable {
        @usableFromInline
        let storage: ContiguousArray<UInt>

        @usableFromInline
        let capacity: Int

        @usableFromInline
        var wordIndex: Int

        @usableFromInline
        var currentWord: UInt

        @usableFromInline
        init(storage: ContiguousArray<UInt>, capacity: Int) {
            self.storage = storage
            self.capacity = capacity
            self.wordIndex = 0
            self.currentWord = storage.isEmpty ? 0 : storage[0]
        }
    }

    /// Returns an iterator over the set's members in ascending order.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: storage, capacity: capacity)
    }
}

// MARK: - Iterator Advancement

extension Bitset.Iterator {
    /// Advances to and returns the next member, or `nil` when exhausted.
    @inlinable
    public mutating func next() -> Int? {
        while currentWord == 0 {
            wordIndex += 1
            guard wordIndex < storage.count else { return nil }
            currentWord = storage[wordIndex]
        }

        let bit = currentWord.trailingZeroBitCount
        currentWord &= currentWord &- 1  // Clear lowest set bit
        let member = wordIndex * UInt.bitWidth + bit
        return member < capacity ? member : nil
    }
}

// MARK: - Iteration

extension Bitset {
    /// Calls the given closure on each member in ascending order.
    ///
    /// - Parameter body: A closure invoked once with each member of the set.
    @inlinable
    public func forEach(_ body: (Int) -> Void) {
        for (wordIndex, var word) in storage.enumerated() {
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * Self.bitsPerWord + bitIndex
                if globalIndex < capacity {
                    body(globalIndex)
                }
                word &= word - 1
            }
        }
    }
}
