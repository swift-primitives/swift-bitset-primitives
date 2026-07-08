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

// MARK: - Hoisted Error Types
//
// Error types are hoisted to module level for typed throws compatibility.
// Use the typealias (e.g., `Bitset.Error`) in your code.

/// Errors that can occur during `Bitset` operations.
public enum __BitsetError: Swift.Error, Sendable, Equatable {
    /// The member is out of bounds.
    case bounds(Bounds)

    /// The specified capacity is invalid.
    case invalidCapacity(InvalidCapacity)
}

extension __BitsetError {
    /// Bounds violation payload.
    public struct Bounds: Sendable, Equatable {
        /// The member whose access fell outside the valid range.
        public let member: Int

        /// The set capacity in effect when the access was attempted.
        public let capacity: Int

        /// Creates a bounds-violation payload.
        @inlinable
        public init(member: Int, capacity: Int) {
            self.member = member
            self.capacity = capacity
        }
    }

    /// Invalid capacity payload.
    public struct InvalidCapacity: Sendable, Equatable {
        /// Creates an invalid-capacity payload.
        @inlinable
        public init() {}
    }
}

// MARK: - Canonical Error Typealias

extension Bitset {
    /// Errors that can occur during bitset operations.
    public typealias Error = __BitsetError
}
