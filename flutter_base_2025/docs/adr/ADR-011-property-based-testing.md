# ADR-011: Property-Based Testing with Glados

## Status

Accepted

## Context

Traditional unit tests verify specific examples, but may miss edge cases. We need a testing strategy that provides stronger correctness guarantees for our generic patterns (Result<T>, Repository<T>, Validator<T>).

## Decision

We adopt Property-Based Testing (PBT) using the Glados library for Dart. PBT generates random inputs to verify that properties hold across all valid inputs.

### Key Properties Tested

| Property | Description | Requirements |
|----------|-------------|--------------|
| Result Monad Laws | Left identity, right identity, associativity | 3.1-3.4 |
| DTO Round-Trip | JSON serialization preserves equality | 4.1-4.2 |
| Pagination hasMore | Correct calculation based on page/total | 5.1, 5.3 |
| Failure Preservation | loadMore failure preserves existing items | 5.4 |
| Exception Mapping | DioException maps to correct AppException | 6.3-6.4 |
| Theme Contrast | Color pairs meet WCAG 4.5:1 ratio | 11.3 |
| Cache TTL | Expired entries trigger re-fetch | 1.5 |
| Validator Composition | CompositeValidator fails if any fails | 13.2 |

### Implementation Pattern

```dart
/// **Feature: feature-name, Property N: Description**
/// **Validates: Requirements X.Y**
Glados<InputType>(iterations: 100).test(
  'property description',
  (input) {
    // Arrange & Act
    final result = systemUnderTest(input);
    
    // Assert property holds
    expect(result, satisfiesProperty);
  },
);
```

### Custom Generators

Located in `test/helpers/generators.dart`:

```dart
extension CustomGenerators on Any {
  Arbitrary<User> get user => combine4(...);
  Arbitrary<Result<T>> result<T>(Arbitrary<T> gen) => ...;
  Arbitrary<AppFailure> get appFailure => ...;
}
```

## Consequences

### Positive

- Catches edge cases that example-based tests miss
- Documents invariants as executable specifications
- Increases confidence in generic implementations
- Finds bugs in serialization/parsing code

### Negative

- Slower test execution (100+ iterations per property)
- Requires learning PBT concepts
- Some properties are hard to express

### Neutral

- Complements but doesn't replace unit tests
- Requires custom generators for domain types

## Configuration

- Minimum 100 iterations per property test
- Custom generators for all domain entities
- Tests annotated with property number and requirements

## References

- [Glados Package](https://pub.dev/packages/glados)
- [Property-Based Testing Introduction](https://hypothesis.works/articles/what-is-property-based-testing/)
