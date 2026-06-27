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

// MARK: - Bitset.Static

extension Bitset {
    /// Fixed-capacity bitset with inline storage.
    ///
    /// `Bitset.Static` uses zero-allocation inline storage with compile-time
    /// capacity. Ideal for small bitsets where heap allocation is unnecessary.
    public struct Static<let wordCount: Int>: Sendable {
        @usableFromInline
        static var bitsPerWord: Int { UInt.bitWidth }

        /// The total number of member slots, equal to `wordCount * bitsPerWord`.
        @inlinable
        public static var capacity: Int { wordCount * bitsPerWord }

        @usableFromInline
        var storage: InlineArray<wordCount, UInt>

        /// Creates an empty static bitset with every bit cleared.
        @inlinable
        public init() {
            self.storage = InlineArray(repeating: 0)
        }

        /// Internal initializer for constructing from storage.
        @usableFromInline
        init(__storage: InlineArray<wordCount, UInt>) {
            self.storage = __storage
        }
    }
}

// MARK: - Properties

extension Bitset.Static {
    /// The total number of member slots available in inline storage.
    @inlinable
    public var capacity: Int { Self.capacity }

    /// The number of members in the set.
    @inlinable
    public var count: Int {
        var total = 0
        for i in 0..<wordCount {
            total += storage[i].nonzeroBitCount
        }
        return total
    }

    /// A Boolean value indicating whether the set contains no members.
    @inlinable
    public var isEmpty: Bool {
        for i in 0..<wordCount {
            if storage[i] != 0 { return false }
        }
        return true
    }
}

// MARK: - Membership

extension Bitset.Static {
    /// Returns whether the set contains the given member.
    @inlinable
    public func contains(_ member: Int) -> Bool {
        guard member >= 0 && member < Self.capacity else { return false }
        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (storage[wordIndex] & mask) != 0
    }
}

// MARK: - Mutation

extension Bitset.Static {
    /// Inserts a member into the set.
    @inlinable
    @discardableResult
    public mutating func insert(_ member: Int) throws(__BitsetStaticError) -> Bool {
        guard member >= 0 && member < Self.capacity else {
            if member >= Self.capacity {
                throw .overflow(.init())
            }
            throw .bounds(.init(member: member, capacity: Self.capacity))
        }
        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        let wasSet = (storage[wordIndex] & mask) != 0
        storage[wordIndex] |= mask
        return !wasSet
    }

    /// Removes a member from the set.
    @inlinable
    @discardableResult
    public mutating func remove(_ member: Int) throws(__BitsetStaticError) -> Bool {
        guard member >= 0 && member < Self.capacity else {
            throw .bounds(.init(member: member, capacity: Self.capacity))
        }
        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        let wasSet = (storage[wordIndex] & mask) != 0
        storage[wordIndex] &= ~mask
        return wasSet
    }

    /// Removes all members, clearing every inline storage word.
    @inlinable
    public mutating func removeAll() {
        for i in 0..<wordCount {
            storage[i] = 0
        }
    }
}

// MARK: - Iteration

extension Bitset.Static {
    /// Calls the given closure on each member in ascending order.
    ///
    /// - Parameter body: A closure invoked once with each member of the set.
    @inlinable
    public func forEach(_ body: (Int) -> Void) {
        for wordIndex in 0..<wordCount {
            var word = storage[wordIndex]
            while word != 0 {
                let bitIndex = word.trailingZeroBitCount
                let globalIndex = wordIndex * Self.bitsPerWord + bitIndex
                body(globalIndex)
                word &= word - 1
            }
        }
    }
}

// MARK: - Equatable

extension Bitset.Static: Equatable {
    /// Returns whether two static bitsets contain the same members.
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in 0..<wordCount {
            if lhs.storage[i] != rhs.storage[i] { return false }
        }
        return true
    }
}

// MARK: - Hashable

extension Bitset.Static: Hashable {
    /// Feeds the set's members into the given hasher.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        for i in 0..<wordCount {
            hasher.combine(storage[i])
        }
    }
}
