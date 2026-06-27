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

extension Bitset {
    /// A result builder for declaratively constructing bitsets.
    ///
    /// Bitset is an integer-domain set; the builder lists the integer
    /// members:
    ///
    /// ```swift
    /// let primes = Bitset {
    ///     2
    ///     3
    ///     5
    ///     7
    ///     11
    /// }
    /// primes.contains(7)  // true
    /// primes.count        // 5
    /// ```
    ///
    /// Members must be non-negative; passing a negative integer to the
    /// builder traps at runtime (mirrors the existing
    /// `Bitset.init<S: Sequence>` convention).
    @resultBuilder
    public enum Builder {

        // MARK: - Expression Building

        /// Lifts a single integer member into a partial component.
        @inlinable
        public static func buildExpression(_ expression: Int) -> [Int] {
            [expression]
        }

        /// Lifts an array of integer members into a partial component.
        @inlinable
        public static func buildExpression(_ expression: [Int]) -> [Int] {
            expression
        }

        /// Bulk-add a sequence of integer members (Range, Set, lazy chain,
        /// etc.) without per-iteration allocation.
        @inlinable
        public static func buildExpression<S: Swift.Sequence>(_ expression: S) -> [Int]
        where S.Element == Int {
            Array(expression)
        }

        /// Lifts an optional integer member into a partial component, dropping `nil`.
        @inlinable
        public static func buildExpression(_ expression: Int?) -> [Int] {
            expression.map { [$0] } ?? []
        }

        // MARK: - Partial Block Building

        /// Begins a block with the first array of members.
        @inlinable
        public static func buildPartialBlock(first: [Int]) -> [Int] {
            first
        }

        /// Begins a block produced by a statement that contributes no members.
        @inlinable
        public static func buildPartialBlock(first: Void) -> [Int] {
            []
        }

        /// Begins a block from a branch that never produces a value.
        @inlinable
        public static func buildPartialBlock(first: Never) -> [Int] {}

        /// Appends the next array of members to those accumulated so far.
        @inlinable
        public static func buildPartialBlock(
            accumulated: consuming [Int],
            next: [Int]
        ) -> [Int] {
            accumulated.append(contentsOf: next)
            return accumulated
        }

        // MARK: - Block Building

        /// Produces an empty member list for an empty builder body.
        @inlinable
        public static func buildBlock() -> [Int] {
            []
        }

        // MARK: - Control Flow

        /// Produces the members of an optional `if` branch, or none when absent.
        @inlinable
        public static func buildOptional(_ component: [Int]?) -> [Int] {
            component ?? []
        }

        /// Produces the members of the first branch of an `if`/`else`.
        @inlinable
        public static func buildEither(first: [Int]) -> [Int] {
            first
        }

        /// Produces the members of the second branch of an `if`/`else`.
        @inlinable
        public static func buildEither(second: [Int]) -> [Int] {
            second
        }

        /// Flattens the members produced by a `for` loop into one list.
        @inlinable
        public static func buildArray(_ components: [[Int]]) -> [Int] {
            components.flatMap { $0 }
        }

        /// Produces the members of a limited-availability (`if #available`) block.
        @inlinable
        public static func buildLimitedAvailability(_ component: [Int]) -> [Int] {
            component
        }
    }
}

// MARK: - Convenience Init

extension Bitset {
    /// Constructs a bitset from a result-builder closure.
    ///
    /// All declared integers are inserted; duplicates collapse (set
    /// semantics) and members must be non-negative.
    ///
    /// ```swift
    /// let evens = Bitset {
    ///     for i in stride(from: 0, to: 10, by: 2) {
    ///         i
    ///     }
    /// }
    /// // 0, 2, 4, 6, 8
    /// ```
    @inlinable
    public init(@Bitset.Builder _ builder: () -> [Int]) throws(__BitsetError) {
        try self.init(builder())
    }
}
