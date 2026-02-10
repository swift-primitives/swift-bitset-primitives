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

// MARK: - Bitset

/// A set of non-negative integers using packed bit storage.
///
/// `Bitset` stores integer members as individual bits in word-sized storage,
/// providing O(1) membership testing and efficient set algebra operations.
/// Space usage is proportional to the maximum member stored, not the number
/// of members.
///
/// ## Variants
///
/// - ``Bitset``: Dynamically-growing storage (this type)
/// - ``Bitset/Fixed``: Fixed-capacity, throws on overflow
/// - ``Bitset/Static``: Zero-allocation inline storage with compile-time capacity
/// - ``Bitset/Small``: Inline storage with automatic spill to heap
public struct Bitset: Sendable {
    @inlinable
    public static var bitsPerWord: Int { UInt.bitWidth }

    @usableFromInline
    var storage: ContiguousArray<UInt>

    @usableFromInline
    var storedCapacity: Int

    @inlinable
    public init() {
        self.storage = []
        self.storedCapacity = 0
    }

    @inlinable
    public init(capacity: Int) throws(__BitsetError) {
        guard capacity >= 0 else {
            throw .invalidCapacity(.init())
        }
        let wordCount = (capacity + Self.bitsPerWord - 1) / Self.bitsPerWord
        self.storage = ContiguousArray(repeating: 0, count: wordCount)
        self.storedCapacity = capacity
    }

    /// Internal initializer for constructing from storage.
    @usableFromInline
    init(__storage: ContiguousArray<UInt>, capacity: Int) {
        self.storage = __storage
        self.storedCapacity = capacity
    }
}

// MARK: - Properties

extension Bitset {
    @inlinable
    public var capacity: Int { storedCapacity }

    @inlinable
    public var count: Int {
        var total = 0
        for word in storage {
            total += word.nonzeroBitCount
        }
        return total
    }

    @inlinable
    public var isEmpty: Bool {
        for word in storage {
            if word != 0 { return false }
        }
        return true
    }

    @usableFromInline
    var wordCount: Int { storage.count }
}

// MARK: - Membership

extension Bitset {
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

extension Bitset {
    @inlinable
    @discardableResult
    public mutating func insert(_ member: Int) throws(__BitsetError) -> Bool {
        guard member >= 0 else {
            throw .bounds(.init(member: member, capacity: capacity))
        }

        if member >= capacity {
            grow(toInclude: member)
        }

        let wordIndex = member / Self.bitsPerWord
        let bitIndex = member % Self.bitsPerWord
        let mask: UInt = 1 << bitIndex
        let wasSet = (storage[wordIndex] & mask) != 0
        storage[wordIndex] |= mask
        return !wasSet
    }

    @inlinable
    @discardableResult
    public mutating func remove(_ member: Int) throws(__BitsetError) -> Bool {
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

    @inlinable
    public mutating func removeAll() {
        for i in 0..<storage.count {
            storage[i] = 0
        }
    }

    @usableFromInline
    mutating func grow(toInclude member: Int) {
        let newCapacity = member + 1
        let newWordCount = (newCapacity + Self.bitsPerWord - 1) / Self.bitsPerWord
        let oldWordCount = storage.count

        if newWordCount > oldWordCount {
            storage.reserveCapacity(newWordCount)
            for _ in oldWordCount..<newWordCount {
                storage.append(0)
            }
        }
        storedCapacity = newCapacity
    }
}

// MARK: - Additional Properties

extension Bitset {
    /// The smallest member in the set, or `nil` if empty.
    ///
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public var min: Int? {
        for wordIndex in storage.indices {
            let word = storage[wordIndex]
            if word != 0 {
                let lowestBit = word.trailingZeroBitCount
                let element = wordIndex * Self.bitsPerWord + lowestBit
                return element < capacity ? element : nil
            }
        }
        return nil
    }

    /// The largest member in the set, or `nil` if empty.
    ///
    /// - Complexity: O(n/w) where w is word bit width
    @inlinable
    public var max: Int? {
        for wordIndex in storage.indices.reversed() {
            let word = storage[wordIndex]
            if word != 0 {
                let highestBit = UInt.bitWidth - 1 - word.leadingZeroBitCount
                let element = wordIndex * Self.bitsPerWord + highestBit
                return element < capacity ? element : nil
            }
        }
        return nil
    }

    /// Removes all members from the set.
    ///
    /// This is an alias for ``removeAll()``.
    @inlinable
    public mutating func clear() {
        removeAll()
    }
}

// MARK: - Additional Initializers

extension Bitset {
    /// Creates a bitset from a sequence of integers.
    ///
    /// - Parameter members: The members to include.
    @inlinable
    public init<S: Swift.Sequence>(_ members: S) where S.Element == Int {
        self.init()
        for member in members {
            try! insert(member)
        }
    }
}

// MARK: - Equatable

extension Bitset: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.storage == rhs.storage && lhs.storedCapacity == rhs.storedCapacity
    }
}

// MARK: - Hashable

extension Bitset: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage)
        hasher.combine(storedCapacity)
    }
}

// MARK: - CustomStringConvertible

extension Bitset: CustomStringConvertible {
    public var description: String {
        let elements = Swift.Array(self.prefix(10))
        let suffix = count > 10 ? ", ..." : ""
        return "Bitset({\(elements.map(String.init).joined(separator: ", "))\(suffix)})"
    }
}
