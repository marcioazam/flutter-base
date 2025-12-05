/// Dart 3.10 Dot Shorthands Examples
///
/// This file demonstrates the new dot shorthand syntax available in Dart 3.10.
/// Dot shorthands allow omitting the class/enum name when the type is inferrable.
///
/// Note: Dot shorthands work when the type can be inferred from context.
/// They do NOT work with `const` constructors that require explicit types.
library;

import 'package:flutter/material.dart';

/// Example widget demonstrating dot shorthands usage.
///
/// Before (Dart 3.9):
/// ```dart
/// Column(
///   mainAxisAlignment: MainAxisAlignment.center,
///   crossAxisAlignment: CrossAxisAlignment.start,
///   children: [...],
/// )
/// ```
///
/// After (Dart 3.10):
/// ```dart
/// Column(
///   mainAxisAlignment: .center,
///   crossAxisAlignment: .start,
///   children: [...],
/// )
/// ```
class DotShorthandsExample extends StatelessWidget {
  const DotShorthandsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      // Dot shorthand for MainAxisAlignment.center
      mainAxisAlignment: .center,
      // Dot shorthand for CrossAxisAlignment.start
      crossAxisAlignment: .start,
      // Dot shorthand for MainAxisSize.min
      mainAxisSize: .min,
      children: [
        // Dot shorthand for TextAlign.center
        Text(
          'Hello Dart 3.10!',
          textAlign: .center,
        ),
        const SizedBox(height: 16),
        // Dot shorthand for Alignment.center
        Align(
          alignment: .center,
          child: Container(
            width: 100,
            height: 100,
            // Dot shorthand for BoxFit.cover
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          // Dot shorthand for MainAxisAlignment.spaceEvenly
          mainAxisAlignment: .spaceEvenly,
          children: [
            _buildButton(context, 'Button 1'),
            _buildButton(context, 'Button 2'),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String label) {
    return ElevatedButton(
      onPressed: () {},
      // Dot shorthand for ButtonStyle properties
      style: ElevatedButton.styleFrom(
        // Dot shorthand for Size
        minimumSize: const Size(100, 48),
      ),
      child: Text(label),
    );
  }
}

/// Example of dot shorthands with enums.
enum Status { pending, active, completed, cancelled }

class StatusWidget extends StatelessWidget {
  final Status status;

  const StatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Dot shorthand in switch expression
    final color = switch (status) {
      .pending => Colors.orange,
      .active => Colors.green,
      .completed => Colors.blue,
      .cancelled => Colors.red,
    };

    // Dot shorthand in if statement
    final icon = status == .completed ? Icons.check : Icons.hourglass_empty;

    return Row(
      mainAxisSize: .min,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(status.name),
      ],
    );
  }
}

/// Example of dot shorthands with named constructors.
class NamedConstructorExample extends StatelessWidget {
  const NamedConstructorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dot shorthand for EdgeInsets.all (when type is inferrable)
        Padding(
          padding: .all(16),
          child: const Text('Padded text'),
        ),
        // Dot shorthand for EdgeInsets.symmetric
        Padding(
          padding: .symmetric(horizontal: 24, vertical: 12),
          child: const Text('Symmetric padding'),
        ),
        // Dot shorthand for EdgeInsets.only
        Padding(
          padding: .only(left: 16, top: 8),
          child: const Text('Only padding'),
        ),
      ],
    );
  }
}

/// Migration guide for existing code:
///
/// 1. Enum values in parameters:
///    - `mainAxisAlignment: MainAxisAlignment.center` → `mainAxisAlignment: .center`
///    - `crossAxisAlignment: CrossAxisAlignment.start` → `crossAxisAlignment: .start`
///
/// 2. Named constructors (when type is inferrable):
///    - `padding: EdgeInsets.all(16)` → `padding: .all(16)`
///    - `alignment: Alignment.center` → `alignment: .center`
///
/// 3. Switch expressions:
///    - `case Status.pending:` → `.pending =>`
///
/// 4. Comparisons:
///    - `status == Status.completed` → `status == .completed`
///
/// Note: `const` constructors still require explicit types:
///    - `const EdgeInsets.all(16)` cannot use dot shorthand
