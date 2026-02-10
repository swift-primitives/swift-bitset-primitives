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

// MARK: - Iteration

extension Bitset.Small {
    /// Calls the given closure on each set member.
    @inlinable
    public func forEach(_ body: (Int) -> Void) {
        let wordCount = wordCount

        for wordIndex in 0..<wordCount {
            var word: UInt
            if let heapStorage = heapStorage {
                word = heapStorage[wordIndex]
            } else {
                word = inlineStorage[wordIndex]
            }

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

// MARK: - Sequence

extension Bitset.Small: Swift.Sequence {
    /// An iterator over the members of a small bitset.
    public struct Iterator: IteratorProtocol {
        @usableFromInline
        let inlineStorage: InlineArray<inlineWordCount, UInt>

        @usableFromInline
        let heapStorage: ContiguousArray<UInt>?

        @usableFromInline
        let capacity: Int

        @usableFromInline
        let wordCount: Int

        @usableFromInline
        var wordIndex: Int

        @usableFromInline
        var currentWord: UInt

        @usableFromInline
        init(
            inlineStorage: InlineArray<inlineWordCount, UInt>,
            heapStorage: ContiguousArray<UInt>?,
            capacity: Int
        ) {
            self.inlineStorage = inlineStorage
            self.heapStorage = heapStorage
            self.capacity = capacity
            self.wordCount = heapStorage?.count ?? inlineWordCount
            self.wordIndex = 0
            if let heap = heapStorage {
                self.currentWord = heap.isEmpty ? 0 : heap[0]
            } else {
                self.currentWord = inlineWordCount > 0 ? inlineStorage[0] : 0
            }
        }

        @inlinable
        public mutating func next() -> Int? {
            while currentWord == 0 {
                wordIndex += 1
                guard wordIndex < wordCount else { return nil }
                if let heap = heapStorage {
                    currentWord = heap[wordIndex]
                } else {
                    currentWord = inlineStorage[wordIndex]
                }
            }

            let bit = currentWord.trailingZeroBitCount
            currentWord &= currentWord &- 1  // Clear lowest set bit
            let member = wordIndex * UInt.bitWidth + bit
            return member < capacity ? member : nil
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(
            inlineStorage: inlineStorage,
            heapStorage: heapStorage,
            capacity: capacity
        )
    }
}
