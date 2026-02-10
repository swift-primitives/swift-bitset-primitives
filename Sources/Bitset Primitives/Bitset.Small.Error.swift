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

/// Errors that can occur during `Bitset.Small` operations.
public enum __BitsetSmallError: Swift.Error, Sendable, Equatable {
    /// The member is out of bounds.
    case bounds(Bounds)

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
}

// MARK: - Canonical Error Typealias

extension Bitset.Small {
    /// Errors that can occur during small bitset operations.
    public typealias Error = __BitsetSmallError
}
