import 'package:flutter_base_2025/core/observability/app_logger.dart';

/// User context for feature flag segmentation.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 21.5**
class UserSegment {

  const UserSegment({
    this.userId,
    this.deviceType,
    this.appVersion,
    this.platform,
    this.customAttributes = const {},
  });
  final String? userId;
  final String? deviceType;
  final String? appVersion;
  final String? platform;
  final Map<String, dynamic> customAttributes;

  Map<String, dynamic> toMap() => {
        if (userId != null) 'userId': userId,
        if (deviceType != null) 'deviceType': deviceType,
        if (appVersion != null) 'appVersion': appVersion,
        if (platform != null) 'platform': platform,
        ...customAttributes,
      };
}

/// Rule for targeting specific user segments.
class TargetingRule {

  const TargetingRule({
    required this.attribute,
    required this.operator,
    required this.value,
  });
  final String attribute;
  final TargetingOperator operator;
  final dynamic value;

  bool evaluate(Map<String, dynamic> context) {
    final contextValue = context[attribute];
    if (contextValue == null) return false;

    final Object? ruleValue = value;

    switch (operator) {
      case TargetingOperator.equals:
        return contextValue == ruleValue;
      case TargetingOperator.notEquals:
        return contextValue != ruleValue;
      case TargetingOperator.contains:
        return contextValue.toString().contains(ruleValue.toString());
      case TargetingOperator.startsWith:
        return contextValue.toString().startsWith(ruleValue.toString());
      case TargetingOperator.endsWith:
        return contextValue.toString().endsWith(ruleValue.toString());
      case TargetingOperator.greaterThan:
        return _compareNumeric(contextValue, ruleValue) > 0;
      case TargetingOperator.lessThan:
        return _compareNumeric(contextValue, ruleValue) < 0;
      case TargetingOperator.inList:
        if (ruleValue is List) return ruleValue.contains(contextValue);
        return false;
      case TargetingOperator.notInList:
        if (ruleValue is List) return !ruleValue.contains(contextValue);
        return true;
      case TargetingOperator.versionGreaterThan:
        return _compareVersions(contextValue.toString(), ruleValue.toString()) > 0;
      case TargetingOperator.versionLessThan:
        return _compareVersions(contextValue.toString(), ruleValue.toString()) < 0;
    }
  }

  int _compareNumeric(dynamic a, dynamic b) {
    final numA = num.tryParse(a.toString()) ?? 0;
    final numB = num.tryParse(b.toString()) ?? 0;
    return numA.compareTo(numB);
  }

  int _compareVersions(String a, String b) {
    final partsA = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final partsB = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final maxLength =
        partsA.length > partsB.length ? partsA.length : partsB.length;

    for (var i = 0; i < maxLength; i++) {
      final partA = i < partsA.length ? partsA[i] : 0;
      final partB = i < partsB.length ? partsB[i] : 0;
      if (partA != partB) return partA.compareTo(partB);
    }
    return 0;
  }
}

enum TargetingOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  endsWith,
  greaterThan,
  lessThan,
  inList,
  notInList,
  versionGreaterThan,
  versionLessThan,
}

/// Feature flag configuration with targeting rules.
class FeatureFlagConfig {

  const FeatureFlagConfig({
    required this.name,
    required this.defaultValue,
    this.rules = const [],
    this.targetedValue,
  });
  final String name;
  final dynamic defaultValue;
  final List<TargetingRule> rules;
  final dynamic targetedValue;

  dynamic evaluate(Map<String, dynamic> context) {
    if (rules.isEmpty) return defaultValue;

    final allRulesMatch = rules.every((rule) => rule.evaluate(context));
    return allRulesMatch ? (targetedValue ?? defaultValue) : defaultValue;
  }
}

/// Abstract interface for feature flags.
abstract interface class FeatureFlags {
  /// Initializes the feature flags service.
  Future<void> initialize();

  /// Fetches latest flags from remote.
  Future<void> fetch();

  /// Sets the user segment for targeting.
  void setUserSegment(UserSegment segment);

  /// Checks if a feature is enabled.
  bool isEnabled(String flagName);

  /// Checks if a feature is enabled for a specific segment.
  bool isEnabledForSegment(String flagName, UserSegment segment);

  /// Gets a typed value for a flag.
  T getValue<T>(String flagName, T defaultValue);

  /// Gets a typed value for a flag with specific segment.
  T getValueForSegment<T>(String flagName, T defaultValue, UserSegment segment);

  /// Gets all flag values.
  Map<String, dynamic> getAllFlags();
}

/// Local feature flags for development with segmentation support.
class LocalFeatureFlags implements FeatureFlags {
  final Map<String, dynamic> _flags = {};
  final Map<String, FeatureFlagConfig> _configs = {};
  UserSegment _currentSegment = const UserSegment();

  final Map<String, dynamic> _defaults = {
    'new_feature_enabled': false,
    'dark_mode_enabled': true,
    'max_items_per_page': 20,
    'api_timeout_seconds': 30,
    'enable_analytics': true,
    'enable_crash_reporting': true,
    'maintenance_mode': false,
  };

  @override
  Future<void> initialize() async {
    _flags.addAll(_defaults);
    AppLogger.instance.info('FeatureFlags initialized (local mode)');
  }

  @override
  Future<void> fetch() async {
    AppLogger.instance.debug('FeatureFlags: fetch called (no-op in local mode)');
  }

  @override
  void setUserSegment(UserSegment segment) {
    _currentSegment = segment;
    AppLogger.instance.debug('FeatureFlags: segment updated - ${segment.toMap()}');
  }

  @override
  bool isEnabled(String flagName) => isEnabledForSegment(flagName, _currentSegment);

  @override
  bool isEnabledForSegment(String flagName, UserSegment segment) {
    final config = _configs[flagName];
    if (config != null) {
      final value = config.evaluate(segment.toMap());
      if (value is bool) return value;
    }

    final value = _flags[flagName];
    if (value is bool) return value;
    return _defaults[flagName] as bool? ?? false;
  }

  @override
  T getValue<T>(String flagName, T defaultValue) => getValueForSegment(flagName, defaultValue, _currentSegment);

  @override
  T getValueForSegment<T>(
      String flagName, T defaultValue, UserSegment segment) {
    final config = _configs[flagName];
    if (config != null) {
      final value = config.evaluate(segment.toMap());
      if (value is T) return value;
    }

    final value = _flags[flagName];
    if (value is T) return value;
    return defaultValue;
  }

  @override
  Map<String, dynamic> getAllFlags() => Map.unmodifiable(_flags);

  /// Sets a flag value (for testing/development).
  void setFlag(String flagName, dynamic value) {
    _flags[flagName] = value;
    AppLogger.instance.debug('FeatureFlags: $flagName = $value');
  }

  /// Sets a flag configuration with targeting rules.
  void setFlagConfig(FeatureFlagConfig config) {
    _configs[config.name] = config;
    AppLogger.instance.debug('FeatureFlags: config set for ${config.name}');
  }

  /// Resets all flags to defaults.
  void reset() {
    _flags
      ..clear()
      ..addAll(_defaults);
    _configs.clear();
    _currentSegment = const UserSegment();
    AppLogger.instance.debug('FeatureFlags: reset to defaults');
  }
}

/// Singleton instance for global access.
class FeatureFlagsService {
  static FeatureFlags? _instance;

  static FeatureFlags get instance {
    _instance ??= LocalFeatureFlags();
    return _instance!;
  }

  static void setInstance(FeatureFlags flags) {
    _instance = flags;
  }
}
