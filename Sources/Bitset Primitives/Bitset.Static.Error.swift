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

/// Errors that can occur during `Bitset.Static` operations.
public enum __BitsetStaticError: Swift.Error, Sendable, Equatable {
    /// The member is out of bounds.
    case bounds(Bounds)

    /// The set is full and cannot accept more members.
    case overflow(Overflow)

    /// Bounds violation payload.
    public struct Bounds: Sendable, Equatable {
        public let member: Int
        public let capacity: Int

        @inlinable
        public init(member: Int, capacity: Int) {
            self.member = member
            self.capacity = capacity
        }
    }

    /// Overflow payload.
    public struct Overflow: Sendable, Equatable {
        @inlinable
        public init() {}
    }
}

// MARK: - Canonical Error Typealias

extension Bitset.Static {
    /// Errors that can occur during static bitset operations.
    public typealias Error = __BitsetStaticError
}
