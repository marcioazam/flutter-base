/// Interface for DTOs with entity conversion.
/// E = Entity type
abstract interface class Dto<E> {
  /// Converts DTO to domain entity.
  E toEntity();

  /// Converts to JSON map.
  Map<String, dynamic> toJson();
}

/// Generic mapper interface.
/// From = Source type, To = Target type
abstract interface class Mapper<From, To> {
  /// Maps single item.
  To map(From from);

  /// Maps list of items.
  List<To> mapList(List<From> items) => items.map(map).toList();
}

/// Extension for pretty-printing DTOs for debugging.
extension DtoPrettyPrint on Map<String, dynamic> {
  /// Returns a formatted JSON string for debugging.
  String toPrettyString({int indent = 2}) {
    return _prettyPrint(this, indent, 0);
  }

  static String _prettyPrint(dynamic value, int indent, int level) {
    final spaces = ' ' * (indent * level);
    final nextSpaces = ' ' * (indent * (level + 1));

    if (value is Map<String, dynamic>) {
      if (value.isEmpty) return '{}';
      final buffer = StringBuffer('{\n');
      final entries = value.entries.toList();
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        buffer.write('$nextSpaces"${entry.key}": ');
        buffer.write(_prettyPrint(entry.value, indent, level + 1));
        if (i < entries.length - 1) buffer.write(',');
        buffer.write('\n');
      }
      buffer.write('$spaces}');
      return buffer.toString();
    } else if (value is List) {
      if (value.isEmpty) return '[]';
      final buffer = StringBuffer('[\n');
      for (var i = 0; i < value.length; i++) {
        buffer.write(nextSpaces);
        buffer.write(_prettyPrint(value[i], indent, level + 1));
        if (i < value.length - 1) buffer.write(',');
        buffer.write('\n');
      }
      buffer.write('$spaces]');
      return buffer.toString();
    } else if (value is String) {
      return '"$value"';
    } else if (value == null) {
      return 'null';
    } else {
      return value.toString();
    }
  }
}

/// Mixin for entities with common fields.
mixin EntityMixin {
  String get id;
  DateTime get createdAt;
  DateTime? get updatedAt;
}
