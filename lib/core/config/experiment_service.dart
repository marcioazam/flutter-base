import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_base_2025/core/observability/analytics_service.dart';
import 'package:flutter_base_2025/core/observability/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Typed variant for A/B testing.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 22.2**
class Variant<T> {

  const Variant({
    required this.name,
    required this.value,
    this.weight = 1.0,
  });
  final String name;
  final T value;
  final double weight;

  Map<String, dynamic> toMap() => {
        'name': name,
        'value': value,
        'weight': weight,
      };
}

/// Experiment configuration.
class Experiment<T> {

  const Experiment({
    required this.id,
    required this.name,
    required this.variants,
    this.isActive = true,
    this.startDate,
    this.endDate,
  });
  final String id;
  final String name;
  final List<Variant<T>> variants;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get isRunning {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  Variant<T>? getVariantByName(String variantName) {
    for (final variant in variants) {
      if (variant.name == variantName) {
        return variant;
      }
    }
    return null;
  }
}

/// User assignment to an experiment variant.
class ExperimentAssignment<T> {

  const ExperimentAssignment({
    required this.experimentId,
    required this.variantName,
    required this.value,
    required this.assignedAt,
  });
  final String experimentId;
  final String variantName;
  final T value;
  final DateTime assignedAt;

  Map<String, dynamic> toMap() => {
        'experimentId': experimentId,
        'variantName': variantName,
        'value': value,
        'assignedAt': assignedAt.toIso8601String(),
      };
}

/// Abstract interface for experiment/A/B testing service.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 22.1, 22.4**
abstract interface class ExperimentService {
  /// Initializes the experiment service.
  Future<void> initialize();

  /// Registers an experiment.
  void registerExperiment<T>(Experiment<T> experiment);

  /// Gets the assigned variant for an experiment.
  Variant<T>? getVariant<T>(String experimentId);

  /// Gets the variant value for an experiment.
  T? getVariantValue<T>(String experimentId);

  /// Forces a specific variant for an experiment.
  void forceVariant(String experimentId, String variantName);

  /// Clears forced variant.
  void clearForcedVariant(String experimentId);

  /// Tracks an event associated with the experiment.
  Future<void> trackExperimentEvent(
    String experimentId,
    String eventName, [
    Map<String, dynamic>? params,
  ]);

  /// Gets all active experiments.
  List<Experiment<dynamic>> getActiveExperiments();

  /// Checks if user is in a specific variant.
  bool isInVariant(String experimentId, String variantName);
}

/// Local experiment service implementation.
class LocalExperimentService implements ExperimentService {

  LocalExperimentService({AnalyticsService? analyticsService})
      : _analyticsService = analyticsService;
  final Map<String, Experiment<dynamic>> _experiments = {};
  final Map<String, String> _assignments = {};
  final Map<String, String> _forcedVariants = {};
  final Random _random = Random();
  final AnalyticsService? _analyticsService;

  SharedPreferences? _prefs;
  static const String _assignmentsKey = 'experiment_assignments';

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAssignments();
    AppLogger.instance.info('ExperimentService initialized');
  }

  void _loadAssignments() {
    final stored = _prefs?.getString(_assignmentsKey);
    if (stored != null) {
      try {
        final decoded = jsonDecode(stored);
        if (decoded is! Map) {
          AppLogger.instance.warning(
            'Type error in experiment assignments: Expected JSON object',
          );
          return;
        }

        var hasInvalidEntry = false;
        for (final entry in decoded.entries) {
          final key = entry.key;
          final value = entry.value;
          if (key is String && value is String) {
            _assignments[key] = value;
          } else {
            hasInvalidEntry = true;
          }
        }

        if (hasInvalidEntry) {
          AppLogger.instance.warning(
            'Type error in experiment assignments: Invalid entry types',
          );
        }
      } on FormatException catch (e) {
        AppLogger.instance.warning('Invalid JSON in experiment assignments: ${e.message}');
      } on Exception catch (e) {
        AppLogger.instance.warning('Failed to load experiment assignments: $e');
      }
    }
  }

  Future<void> _saveAssignments() async {
    await _prefs?.setString(_assignmentsKey, jsonEncode(_assignments));
  }

  @override
  void registerExperiment<T>(Experiment<T> experiment) {
    _experiments[experiment.id] = experiment;
    AppLogger.instance.debug('Experiment registered: ${experiment.id}');
  }

  @override
  Variant<T>? getVariant<T>(String experimentId) {
    final experiment = _experiments[experimentId];
    if (experiment == null || !experiment.isRunning) return null;

    final forcedVariant = _forcedVariants[experimentId];
    if (forcedVariant != null) {
      return experiment.getVariantByName(forcedVariant) as Variant<T>?;
    }

    var assignedVariant = _assignments[experimentId];
    if (assignedVariant == null) {
      assignedVariant = _assignVariant(experiment);
      _assignments[experimentId] = assignedVariant;
      _saveAssignments();
    }

    return experiment.getVariantByName(assignedVariant) as Variant<T>?;
  }

  String _assignVariant(Experiment<dynamic> experiment) {
    final totalWeight =
        experiment.variants.fold<double>(0, (sum, v) => sum + v.weight);
    var randomValue = _random.nextDouble() * totalWeight;

    for (final variant in experiment.variants) {
      randomValue -= variant.weight;
      if (randomValue <= 0) {
        return variant.name;
      }
    }

    return experiment.variants.last.name;
  }

  @override
  T? getVariantValue<T>(String experimentId) => getVariant<T>(experimentId)?.value;

  @override
  void forceVariant(String experimentId, String variantName) {
    _forcedVariants[experimentId] = variantName;
    AppLogger.instance.debug('Forced variant: $experimentId -> $variantName');
  }

  @override
  void clearForcedVariant(String experimentId) {
    _forcedVariants.remove(experimentId);
    AppLogger.instance.debug('Cleared forced variant: $experimentId');
  }

  @override
  Future<void> trackExperimentEvent(
    String experimentId,
    String eventName, [
    Map<String, dynamic>? params,
  ]) async {
    final variant = getVariant<dynamic>(experimentId);
    if (variant == null) return;

    final eventParams = {
      'experiment_id': experimentId,
      'variant_name': variant.name,
      ...?params,
    };

    await _analyticsService?.logEvent(name: eventName, parameters: eventParams);
    AppLogger.instance.debug('Experiment event: $eventName - $eventParams');
  }

  @override
  List<Experiment<dynamic>> getActiveExperiments() => _experiments.values.where((e) => e.isRunning).toList();

  @override
  bool isInVariant(String experimentId, String variantName) {
    final variant = getVariant<dynamic>(experimentId);
    return variant?.name == variantName;
  }

  /// Clears all assignments (for testing).
  @visibleForTesting
  Future<void> clearAllAssignments() async {
    _assignments.clear();
    _forcedVariants.clear();
    await _prefs?.remove(_assignmentsKey);
  }
}

/// Singleton for global access.
class ExperimentServiceProvider {
  static ExperimentService? _instance;

  static ExperimentService get instance {
    _instance ??= LocalExperimentService();
    return _instance!;
  }

  static void setInstance(ExperimentService service) {
    _instance = service;
  }
}
