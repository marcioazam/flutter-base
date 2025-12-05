# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Dart classes
-keep class * extends io.flutter.embedding.engine.FlutterEngine { *; }

# Drift/SQLite rules
-keep class * extends drift.** { *; }
