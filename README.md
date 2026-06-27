# Bitset Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Packed-bit set types for non-negative integers — a growable `Bitset`, a fixed-capacity `Bitset.Fixed`, and an inline-storage `Bitset.Static` — with set algebra, set relations, and result-builder construction.

---

## Quick Start

A `Bitset` stores integer members as individual bits in word-sized storage: O(1) membership testing, popcount-based `count`, and word-parallel set algebra. Space tracks the largest member stored, not the member count. Build one declaratively with the result builder, then ask it questions:

```swift
import Bitset_Primitives

// Declare a set of small non-negative integers.
let primes = Bitset {
    2
    3
    5
    7
    11
}

primes.contains(7)   // true
primes.count         // 5
primes.min           // Optional(2)

// Build another from any Sequence of Int.
let evens = Bitset(stride(from: 0, to: 12, by: 2))   // 0, 2, 4, 6, 8, 10

// Set algebra returns new bitsets; relations return Bool.
let union = primes.algebra.union(evens)
let common = primes.algebra.intersection(evens)      // {2}
primes.relation.isDisjoint(with: evens)              // false — both hold 2

// Bitset is a Sequence, yielding members in ascending order.
for member in union { print(member) }
```

When capacity is known ahead of time, the bounded variants trade growth for predictable storage and an explicit overflow error:

```swift
import Bitset_Primitives

// Heap-allocated, fixed capacity — throws on overflow instead of growing.
var fixed = try Bitset.Fixed(capacity: 128)
try fixed.insert(64)

// Inline, zero-allocation storage; capacity is wordCount * UInt.bitWidth.
var inline = Bitset.Static<2>()   // 128 slots on a 64-bit platform, no heap
try inline.insert(100)
inline.contains(100)              // true
```

`Bitset.Static<let wordCount: Int>` carries its word count in the type, so its capacity is fixed at compile time and its storage lives inline with no allocation.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-bitset-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Bitset Primitives", package: "swift-bitset-primitives"),
    ]
)
```

---

## Architecture

Two library products. The core library depends only on the `Iterator.Protocol` primitive.

| Product | Target | Purpose |
|---------|--------|---------|
| `Bitset Primitives` | `Sources/Bitset Primitives/` | The `Bitset` namespace: the growable `Bitset`, the bounded `Bitset.Fixed`, and the inline `Bitset.Static`; the `.algebra` accessor (`union`, `intersection`, `subtract`, `symmetric.difference`); the `.relation` accessor (`isSubset(of:)`, `isSuperset(of:)`, `isDisjoint(with:)`); the `Bitset.Builder` result builder; and `Sequence`, `Equatable`, `Hashable`, and `CustomStringConvertible` conformances. |
| `Bitset Primitives Test Support` | `Tests/Support/` | Re-exports the main target for test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
