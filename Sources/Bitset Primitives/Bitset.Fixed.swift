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

// MARK: - Bitset.Fixed

extension Bitset {
    /// Fixed-capacity bitset.
    ///
    /// `Bitset.Fixed` allocates storage upfront and throws on overflow.
    /// Use this variant when capacity is known or in contexts requiring
    /// predictable memory behavior.
    public struct Fixed: Sendable {
        @usableFromInline
        static var bitsPerWord: Int { UInt.bitWidth }

        @usableFromInline
        var storage: ContiguousArray<UInt>

        /// The fixed number of member slots allocated at initialization.
        public let capacity: Int

        /// Creates a fixed-capacity bitset with storage for members in `0..<capacity`.
        ///
        /// - Parameter capacity: The number of member slots to allocate; must be non-negative.
        /// - Throws: `Bitset.Fixed.Error.invalidCapacity` when `capacity` is negative.
        @inlinable
        public init(capacity: Int) throws(__BitsetFixedError) {
            guard capacity >= 0 else {
                throw .invalidCapacity(.init())
            }
            let wordCount = (capacity + Self.bitsPerWord - 1) / Self.bitsPerWord
            self.storage = ContiguousArray(repeating: 0, count: wordCount)
            self.capacity = capacity
        }

        /// Internal initializer for constructing from storage.
        @usableFromInline
        init(__storage: ContiguousArray<UInt>, capacity: Int) {
            self.storage = __storage
            self.capacity = capacity
        }
    }
}

// MARK: - Properties

extension Bitset.Fixed {
    /// The number of members in the set.
    @inlinable
    public var count: Int {
        var total = 0
        for word in storage {
            total += word.nonzeroBitCount
        }
        return total
    }

    /// A Boolean value indicating whether the set contains no members.
    @inlinable
    public var isEmpty: Bool {
        for word in storage {
            if word != 0 { return false }
        }
        return true
    }
}

// MARK: - Membership

extension Bitset.Fixed {
    /// Returns whether the set contains the given member.
    @inlinable
    public func contains(_ member: Int) -> Bool {
        guard member >= 0 && member < capacity else { return false }
        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        return (storage[wordIndex] & mask) != 0
    }
}

// MARK: - Mutation

extension Bitset.Fixed {
    /// Inserts a member into the set.
    @inlinable
    @discardableResult
    public mutating func insert(_ member: Int) throws(__BitsetFixedError) -> Bool {
        guard member >= 0 && member < capacity else {
            if member >= capacity {
                throw .overflow(.init())
            }
            throw .bounds(.init(member: member, capacity: capacity))
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
    public mutating func remove(_ member: Int) throws(__BitsetFixedError) -> Bool {
        guard member >= 0 && member < capacity else {
            throw .bounds(.init(member: member, capacity: capacity))
        }
        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        let wasSet = (storage[wordIndex] & mask) != 0
        storage[wordIndex] &= ~mask
        return wasSet
    }

    /// Removes all members, leaving the fixed capacity intact.
    @inlinable
    public mutating func removeAll() {
        for i in 0..<storage.count {
            storage[i] = 0
        }
    }
}

// MARK: - Iteration

extension Bitset.Fixed {
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

// MARK: - Equatable

extension Bitset.Fixed: Equatable {
    /// Returns whether two fixed bitsets have equal capacity and members.
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.capacity == rhs.capacity && lhs.storage == rhs.storage
    }
}

// MARK: - Hashable

extension Bitset.Fixed: Hashable {
    /// Feeds the set's capacity and members into the given hasher.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(capacity)
        hasher.combine(storage)
    }
}
