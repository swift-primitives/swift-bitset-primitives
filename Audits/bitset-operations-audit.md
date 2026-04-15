# Bitset Operations Audit

<!--
---
version: 1.0.0
last_updated: 2026-02-16
status: RECOMMENDATION
tier: 1
---
-->

## Context

Proactive audit of swift-bitset-primitives per [RES-012] Discovery.
**Scope**: Package-specific (swift-bitset-primitives).

## Question

Does swift-bitset-primitives provide the canonical operations expected of the Bitset ADT?

## Canonical Operations (ADT Reference)

| Operation | Expected Complexity | Description |
|-----------|-------------------|-------------|
| set(i) | O(1) | Set bit at position |
| clear(i) | O(1) | Clear bit at position |
| toggle(i) | O(1) | Flip bit at position |
| test(i) | O(1) | Check bit at position |
| count_ones() / popcount | O(m/w) | Count set bits |
| any | O(m/w) worst | Any bit set? |
| all | O(m/w) worst | All bits set? |
| none | O(m/w) worst | No bits set? |
| union (OR) | O(m/w) | Bitwise OR |
| intersection (AND) | O(m/w) | Bitwise AND |
| difference (AND NOT) | O(m/w) | Bitwise AND NOT |
| symmetric_difference (XOR) | O(m/w) | Bitwise XOR |
| next_set_bit(i) | O(m/w) worst | Find next set bit |
| count/size | O(1) | Number of bits |
| isEmpty | O(m/w) | All zeros? |

(m = number of bits, w = word size e.g. 64)

## Current Operations Inventory

### Core (Bitset -- dynamic)

**File**: `Bitset.swift`

| Category | Signature | Notes |
|----------|-----------|-------|
| Init | `public init()` | Empty bitset |
| Init | `public init(capacity: Int) throws(__BitsetError)` | Pre-allocated |
| Init | `public init<S: Sequence>(_ members: S) where S.Element == Int` | From sequence |
| Property | `public static var bitsPerWord: Int` | `UInt.bitWidth` (64) |
| Property | `public var capacity: Int` | Current universe size, O(1) |
| Property | `public var count: Int` | Popcount, O(m/w) |
| Property | `public var isEmpty: Bool` | Any-zero check, O(m/w) |
| Property | `public var min: Int?` | Smallest set member, O(m/w) |
| Property | `public var max: Int?` | Largest set member, O(m/w) |
| Membership | `public func contains(_ member: Int) -> Bool` | Test bit, O(1) |
| Mutation | `public mutating func insert(_ member: Int) throws(__BitsetError) -> Bool` | Set bit (auto-grows), O(1) amortized |
| Mutation | `public mutating func remove(_ member: Int) throws(__BitsetError) -> Bool` | Clear bit, O(1) |
| Mutation | `public mutating func removeAll()` | Clear all bits, O(m/w) |
| Mutation | `public mutating func clear()` | Alias for `removeAll()`, O(m/w) |
| Mutation | `public mutating func form(_ operation: (Algebra) -> Bitset)` | Apply algebra in-place |
| Iteration | `public func forEach(_ body: (Int) -> Void)` | Sparse iteration, O(popcount) |
| Iteration | `public func makeIterator() -> Iterator` | `Sequence` conformance |
| Conformance | `Sendable` | |
| Conformance | `Equatable` | |
| Conformance | `Hashable` | |
| Conformance | `Sequence` (via `Swift.Sequence`) | |
| Conformance | `CustomStringConvertible` | |

**Error type**: `Bitset.Error` (typealias to `__BitsetError`)
- `.bounds(Bounds)` -- member out of range
- `.invalidCapacity(InvalidCapacity)` -- negative capacity

### Variant: Fixed (Bitset.Fixed)

**File**: `Bitset.Fixed.swift`

| Category | Signature | Notes |
|----------|-----------|-------|
| Init | `public init(capacity: Int) throws(__BitsetFixedError)` | Fixed allocation |
| Property | `public let capacity: Int` | Immutable capacity, O(1) |
| Property | `public var count: Int` | Popcount, O(m/w) |
| Property | `public var isEmpty: Bool` | O(m/w) |
| Membership | `public func contains(_ member: Int) -> Bool` | O(1) |
| Mutation | `public mutating func insert(_ member: Int) throws(__BitsetFixedError) -> Bool` | Throws on overflow |
| Mutation | `public mutating func remove(_ member: Int) throws(__BitsetFixedError) -> Bool` | O(1) |
| Mutation | `public mutating func removeAll()` | O(m/w) |
| Mutation | `public mutating func form(_ operation: (Algebra) -> Bitset.Fixed)` | Apply algebra in-place |
| Iteration | `public func forEach(_ body: (Int) -> Void)` | Sparse iteration |
| Conformance | `Sendable` | |
| Conformance | `Equatable` | |
| Conformance | `Hashable` | |

**Error type**: `Bitset.Fixed.Error` (typealias to `__BitsetFixedError`)
- `.bounds(Bounds)` -- member out of range
- `.invalidCapacity(InvalidCapacity)` -- negative capacity
- `.overflow(Overflow)` -- member exceeds fixed capacity

**Not a `Sequence`**: `Bitset.Fixed` does not conform to `Swift.Sequence` (no `makeIterator()`). It only has `forEach`.

### Variant: Static (Bitset.Static\<let wordCount: Int\>)

**File**: `Bitset.Static.swift`

| Category | Signature | Notes |
|----------|-----------|-------|
| Init | `public init()` | All-zeros inline storage |
| Property | `public static var capacity: Int` | Compile-time: `wordCount * bitsPerWord` |
| Property | `public var capacity: Int` | Instance accessor for above |
| Property | `public var count: Int` | Popcount, O(m/w) |
| Property | `public var isEmpty: Bool` | O(m/w) |
| Membership | `public func contains(_ member: Int) -> Bool` | O(1) |
| Mutation | `public mutating func insert(_ member: Int) throws(__BitsetStaticError) -> Bool` | Throws on overflow |
| Mutation | `public mutating func remove(_ member: Int) throws(__BitsetStaticError) -> Bool` | O(1) |
| Mutation | `public mutating func removeAll()` | O(m/w) |
| Mutation | `public mutating func form(_ operation: (Algebra) -> Bitset.Static<wordCount>)` | Apply algebra in-place |
| Iteration | `public func forEach(_ body: (Int) -> Void)` | Sparse iteration |
| Conformance | `Sendable` | |
| Conformance | `Equatable` | |
| Conformance | `Hashable` | |

**Error type**: `Bitset.Static.Error` (typealias to `__BitsetStaticError`)
- `.bounds(Bounds)` -- member out of range
- `.overflow(Overflow)` -- member exceeds static capacity

**Not a `Sequence`**: `Bitset.Static` does not conform to `Swift.Sequence` (no `makeIterator()`). It only has `forEach`.

### Variant: Small (Bitset.Small\<let inlineWordCount: Int\>)

**File**: `Bitset.Small.swift`

| Category | Signature | Notes |
|----------|-----------|-------|
| Init | `public init()` | Inline storage, zero allocation |
| Property | `public static var inlineCapacity: Int` | `inlineWordCount * bitsPerWord` |
| Property | `public var capacity: Int` | Current capacity (grows on spill) |
| Property | `public var count: Int` | Popcount, O(m/w) |
| Property | `public var isEmpty: Bool` | O(m/w) |
| Property | `public var isSpilled: Bool` | Whether heap-allocated |
| Property | `public var min: Int?` | Smallest set member, O(m/w) |
| Property | `public var max: Int?` | Largest set member, O(m/w) |
| Membership | `public func contains(_ member: Int) -> Bool` | O(1) |
| Mutation | `public mutating func insert(_ member: Int) throws(__BitsetSmallError) -> Bool` | Auto-spills to heap |
| Mutation | `public mutating func remove(_ member: Int) throws(__BitsetSmallError) -> Bool` | O(1) |
| Mutation | `public mutating func removeAll()` | Clears bits (keeps mode) |
| Mutation | `public mutating func clear()` | Resets to inline mode |
| Mutation | `public mutating func form(_ operation: (Algebra) -> Bitset.Small<inlineWordCount>)` | Apply algebra in-place |
| Iteration | `public func forEach(_ body: (Int) -> Void)` | Sparse iteration |
| Iteration | `public func makeIterator() -> Iterator` | `Sequence` conformance |
| Conformance | `Sendable` | |
| Conformance | `Equatable` | |
| Conformance | `Hashable` | |
| Conformance | `Sequence` (via `Swift.Sequence`) | |
| Conformance | `CustomStringConvertible` | |

**Error type**: `Bitset.Small.Error` (typealias to `__BitsetSmallError`)
- `.bounds(Bounds)` -- member out of range

### Set Algebra Operations

All four variants expose algebra via the `algebra` nested accessor pattern:

```swift
a.algebra.union(b)
a.algebra.intersection(b)
a.algebra.subtract(b)
a.algebra.symmetric.difference(b)
a.form { $0.union(b) }  // mutating
```

| Variant | union | intersection | subtract (difference) | symmetric.difference | form (mutating) |
|---------|-------|-------------|----------------------|---------------------|-----------------|
| `Bitset` | `Algebra.union(_ other: Bitset) -> Bitset` | `Algebra.intersection(_ other: Bitset) -> Bitset` | `Algebra.subtract(_ other: Bitset) -> Bitset` | `Algebra.Symmetric.difference(_ other: Bitset) -> Bitset` | `form(_ operation: (Algebra) -> Bitset)` |
| `Bitset.Fixed` | `Algebra.union(_ other: Fixed) -> Fixed` | `Algebra.intersection(_ other: Fixed) -> Fixed` | `Algebra.subtract(_ other: Fixed) -> Fixed` | `Algebra.Symmetric.difference(_ other: Fixed) -> Fixed` | `form(_ operation: (Algebra) -> Fixed)` |
| `Bitset.Static<N>` | `Algebra.union(_ other: Static<N>) -> Static<N>` | `Algebra.intersection(_ other: Static<N>) -> Static<N>` | `Algebra.subtract(_ other: Static<N>) -> Static<N>` | `Algebra.Symmetric.difference(_ other: Static<N>) -> Static<N>` | `form(_ operation: (Algebra) -> Static<N>)` |
| `Bitset.Small<N>` | `Algebra.union(_ other: Small<N>) -> Small<N>` | `Algebra.intersection(_ other: Small<N>) -> Small<N>` | `Algebra.subtract(_ other: Small<N>) -> Small<N>` | `Algebra.Symmetric.difference(_ other: Small<N>) -> Small<N>` | `form(_ operation: (Algebra) -> Small<N>)` |

**Notes**:
- `Bitset.Fixed` and `Bitset.Static` algebra operations precondition on matching capacity.
- `Bitset` (dynamic) and `Bitset.Small` handle mismatched sizes by growing the result.
- All algebra operations are non-mutating. The `form` method is the mutating entry point.

### Relation Operations (subset, superset, disjoint)

All four variants expose relations via the `relation` nested accessor pattern:

```swift
a.relation.isSubset(of: b)
a.relation.isSuperset(of: b)
a.relation.isDisjoint(with: b)
```

| Variant | isSubset(of:) | isSuperset(of:) | isDisjoint(with:) |
|---------|-------------|----------------|-------------------|
| `Bitset` | `Relation.isSubset(of other: Bitset) -> Bool` | `Relation.isSuperset(of other: Bitset) -> Bool` | `Relation.isDisjoint(with other: Bitset) -> Bool` |
| `Bitset.Fixed` | `Relation.isSubset(of other: Fixed) -> Bool` | `Relation.isSuperset(of other: Fixed) -> Bool` | `Relation.isDisjoint(with other: Fixed) -> Bool` |
| `Bitset.Static<N>` | `Relation.isSubset(of other: Static<N>) -> Bool` | `Relation.isSuperset(of other: Static<N>) -> Bool` | `Relation.isDisjoint(with other: Static<N>) -> Bool` |
| `Bitset.Small<N>` | `Relation.isSubset(of other: Small<N>) -> Bool` | `Relation.isSuperset(of other: Small<N>) -> Bool` | `Relation.isDisjoint(with other: Small<N>) -> Bool` |

**Notes**:
- `Bitset.Fixed` and `Bitset.Static` precondition on matching capacity.
- `Bitset` and `Bitset.Small` handle mismatched sizes correctly.

### Iteration (Bitset.Iterator, Bitset.Small.Iterator)

| Type | Conformance | Technique |
|------|------------|-----------|
| `Bitset.Iterator` | `IteratorProtocol`, `Sequence.Iterator.Protocol`, `Sendable` | Wegner/Kernighan sparse: `word &= word &- 1` |
| `Bitset.Small.Iterator` | `IteratorProtocol`, `Sequence.Iterator.Protocol` | Same technique, dual-mode (inline/heap) |

Both yield members in **ascending order** with O(popcount) complexity.

`Bitset.Fixed` and `Bitset.Static` do **not** have `Iterator` types; they provide only `forEach`.

### Additional Operations (beyond canonical)

| Operation | Variant(s) | Description |
|-----------|-----------|-------------|
| `min: Int?` | `Bitset`, `Bitset.Small` | Smallest set member |
| `max: Int?` | `Bitset`, `Bitset.Small` | Largest set member |
| `isSpilled: Bool` | `Bitset.Small` | Whether using heap storage |
| `clear()` (reset to inline) | `Bitset.Small` | Distinct from `removeAll()` -- resets spill state |
| `clear()` (alias) | `Bitset` | Alias for `removeAll()` |
| `Sequence` conformance | `Bitset`, `Bitset.Small` | Full `Swift.Sequence` with `makeIterator()` |
| `CustomStringConvertible` | `Bitset`, `Bitset.Small` | Debug descriptions |
| `init<S: Sequence>(_ members:)` | `Bitset` | Construct from member sequence |

## Gap Analysis

### Present and Correctly Mapped

| Canonical Operation | Mapped To | Coverage |
|--------------------|-----------|----------|
| set(i) | `insert(_ member:)` | All 4 variants |
| clear(i) | `remove(_ member:)` | All 4 variants |
| test(i) | `contains(_ member:)` | All 4 variants |
| count_ones() / popcount | `count: Int` | All 4 variants |
| isEmpty | `isEmpty: Bool` | All 4 variants |
| union (OR) | `algebra.union(_:)` | All 4 variants |
| intersection (AND) | `algebra.intersection(_:)` | All 4 variants |
| difference (AND NOT) | `algebra.subtract(_:)` | All 4 variants |
| symmetric_difference (XOR) | `algebra.symmetric.difference(_:)` | All 4 variants |
| count/size | `capacity: Int` | All 4 variants |

### Missing -- Should Add (Primitives Layer)

| Canonical Operation | Status | Recommendation |
|--------------------|--------|----------------|
| **toggle(i)** | **MISSING on all 4 variants** | Add `mutating func toggle(_ member: Int) throws(Error)`. This is a fundamental O(1) bitset primitive (`word ^= mask`). Every variant should have it. |
| **any** | **Partially present** | `isEmpty` answers `none`, so `!isEmpty` gives `any`. Consider adding an explicit `var any: Bool` property for clarity, or accept that `!isEmpty` is sufficient. Low priority. |
| **all** | **MISSING on all 4 variants** | Add `var all: Bool` (or `var isFull: Bool`). Checks whether every bit in the capacity is set. Semantically distinct from `!isEmpty`. Relevant for fixed-capacity variants (`Fixed`, `Static`) where "all bits set" has clear meaning. For dynamic `Bitset`, the semantics are capacity-dependent. |
| **none** | **Present as `isEmpty`** | Correctly mapped. No action. |
| **next_set_bit(i)** | **MISSING on all 4 variants** | Add `func nextSetBit(from position: Int) -> Int?`. This is a core primitive for iteration control, range scans, and sparse algorithms. The iterator uses the technique internally but does not expose it as a standalone query. |

### Missing -- Intentionally Absent (Higher Layer)

| Operation | Rationale |
|-----------|-----------|
| `Sequence` on `Fixed` / `Static` | These variants provide `forEach` but not `makeIterator()`. Adding `Sequence` conformance is reasonable at the primitives layer but may have been deferred intentionally. This should be a separate deliberate decision. |
| `min` / `max` on `Fixed` / `Static` | Present on `Bitset` and `Bitset.Small` but absent on `Fixed` and `Static`. These are derivable from `next_set_bit` but are convenient properties. Worth adding for parity. |
| Complement / invert | `~self` (bitwise NOT). Creates a bitset with all bits flipped within the capacity. This is a higher-level operation because it depends on capacity semantics. Could live at primitives layer for `Fixed` and `Static` where capacity is well-defined. |
| Shift left / right | Bitwise shift of the entire bitset. Not a core set-algebra operation. Higher layer. |
| Rank / select | `rank(i)` = count of set bits below position i. `select(k)` = position of k-th set bit. These are advanced succinct data structure operations. Higher layer. |
| `SetAlgebra` conformance | Swift's `SetAlgebra` protocol. The package uses its own `algebra` accessor pattern instead, which is more composable and avoids the `SetAlgebra` requirement for `ExpressibleByArrayLiteral`. Intentionally absent. |

## Summary of Gaps by Variant

| Gap | `Bitset` | `Fixed` | `Static` | `Small` |
|-----|----------|---------|----------|---------|
| `toggle(_:)` | MISSING | MISSING | MISSING | MISSING |
| `all` / `isFull` | MISSING | MISSING | MISSING | MISSING |
| `nextSetBit(from:)` | MISSING | MISSING | MISSING | MISSING |
| `Sequence` conformance | Present | MISSING | MISSING | Present |
| `min` / `max` | Present | MISSING | MISSING | Present |

## Outcome

**Status**: RECOMMENDATION

Three canonical operations are absent from all four variants:

1. **`toggle(_:)`** -- Fundamental O(1) primitive. Straightforward to implement (`word ^= mask`). Should be added to all variants.
2. **`all` / `isFull`** -- Canonical completeness predicate. Most meaningful for `Fixed` and `Static` where capacity is well-defined. Should be added with clear capacity semantics.
3. **`nextSetBit(from:)`** -- Core scanning primitive. The internal iteration already uses this technique. Exposing it as a public method enables efficient external algorithms without requiring full iteration.

Secondary gaps (parity across variants):

4. **`Sequence` conformance** on `Fixed` and `Static` -- these have `forEach` but no `makeIterator()`. Adding `Iterator` types would bring parity with `Bitset` and `Bitset.Small`.
5. **`min` / `max`** on `Fixed` and `Static` -- present on the dynamic variants but missing from the fixed-capacity ones.

None of the missing operations require Foundation or violate the primitives layer contract. All are O(1) or O(m/w) and are implementable with pure bitwise arithmetic.
