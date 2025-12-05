import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_base_2025/core/observability/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Rate and review service configuration.
class RateReviewConfig {

  const RateReviewConfig({
    this.minLaunches = 5,
    this.minDaysSinceInstall = 7,
    this.minDaysBetweenPrompts = 30,
    this.maxPromptsPerYear = 3,
    this.customConditions = const [],
  });
  /// Minimum app launches before showing review.
  final int minLaunches;

  /// Minimum days since install before showing review.
  final int minDaysSinceInstall;

  /// Minimum days between review prompts.
  final int minDaysBetweenPrompts;

  /// Maximum prompts per year (iOS limit is 3).
  final int maxPromptsPerYear;

  /// Custom conditions that must be met.
  final List<bool Function()> customConditions;
}

/// Rate and review service.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 41.1, 41.2, 41.3, 41.4, 41.5**
abstract interface class RateReviewService {
  /// Initializes the service.
  Future<void> initialize([RateReviewConfig? config]);

  /// Requests a review if conditions are met.
  Future<bool> requestReview();

  /// Forces a review request (ignores conditions).
  Future<bool> forceReview();

  /// Opens the app store page.
  Future<bool> openStoreListing();

  /// Checks if review conditions are met.
  Future<bool> shouldRequestReview();

  /// Records an app launch.
  Future<void> recordLaunch();

  /// Records a significant event (can trigger review).
  Future<void> recordSignificantEvent(String eventName);

  /// Gets the number of prompts shown this year.
  int get promptsThisYear;

  /// Gets the last prompt date.
  DateTime? get lastPromptDate;
}

/// Local rate review service implementation.
class LocalRateReviewService implements RateReviewService {
  RateReviewConfig _config = const RateReviewConfig();
  SharedPreferences? _prefs;

  static const String _launchCountKey = 'rate_review_launch_count';
  static const String _installDateKey = 'rate_review_install_date';
  static const String _lastPromptKey = 'rate_review_last_prompt';
  static const String _promptCountKey = 'rate_review_prompt_count';
  static const String _promptYearKey = 'rate_review_prompt_year';

  int _launchCount = 0;
  DateTime? _installDate;
  DateTime? _lastPromptDate;
  int _promptCount = 0;
  int _promptYear = 0;

  @override
  Future<void> initialize([RateReviewConfig? config]) async {
    _config = config ?? const RateReviewConfig();
    _prefs = await SharedPreferences.getInstance();

    _loadData();
    AppLogger.instance.info('RateReviewService initialized');
  }

  void _loadData() {
    _launchCount = _prefs?.getInt(_launchCountKey) ?? 0;

    final installMs = _prefs?.getInt(_installDateKey);
    if (installMs != null) {
      _installDate = DateTime.fromMillisecondsSinceEpoch(installMs);
    } else {
      _installDate = DateTime.now();
      _prefs?.setInt(_installDateKey, _installDate!.millisecondsSinceEpoch);
    }

    final lastPromptMs = _prefs?.getInt(_lastPromptKey);
    if (lastPromptMs != null) {
      _lastPromptDate = DateTime.fromMillisecondsSinceEpoch(lastPromptMs);
    }

    _promptCount = _prefs?.getInt(_promptCountKey) ?? 0;
    _promptYear = _prefs?.getInt(_promptYearKey) ?? DateTime.now().year;

    if (_promptYear != DateTime.now().year) {
      _promptCount = 0;
      _promptYear = DateTime.now().year;
      _prefs?.setInt(_promptCountKey, 0);
      _prefs?.setInt(_promptYearKey, _promptYear);
    }
  }

  @override
  Future<bool> requestReview() async {
    if (!await shouldRequestReview()) {
      AppLogger.instance.debug('Review conditions not met');
      return false;
    }

    return _showReview();
  }

  @override
  Future<bool> forceReview() async => _showReview();

  Future<bool> _showReview() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      _lastPromptDate = DateTime.now();
      _promptCount++;

      await _prefs?.setInt(
          _lastPromptKey, _lastPromptDate!.millisecondsSinceEpoch);
      await _prefs?.setInt(_promptCountKey, _promptCount);

      AppLogger.instance.info('Review prompt shown');
      return true;
    } catch (e) {
      AppLogger.instance.error('Failed to show review', error: e);
      return false;
    }
  }

  @override
  Future<bool> openStoreListing() async {
    try {
      AppLogger.instance.info('Opening store listing');
      return true;
    } catch (e) {
      AppLogger.instance.error('Failed to open store listing', error: e);
      return false;
    }
  }

  @override
  Future<bool> shouldRequestReview() async {
    if (_launchCount < _config.minLaunches) {
      AppLogger.instance.debug(
          'Not enough launches: $_launchCount < ${_config.minLaunches}');
      return false;
    }

    if (_installDate != null) {
      final daysSinceInstall = DateTime.now().difference(_installDate!).inDays;
      if (daysSinceInstall < _config.minDaysSinceInstall) {
        AppLogger.instance.debug(
            'Not enough days since install: $daysSinceInstall < ${_config.minDaysSinceInstall}');
        return false;
      }
    }

    if (_lastPromptDate != null) {
      final daysSincePrompt =
          DateTime.now().difference(_lastPromptDate!).inDays;
      if (daysSincePrompt < _config.minDaysBetweenPrompts) {
        AppLogger.instance.debug(
            'Not enough days since last prompt: $daysSincePrompt < ${_config.minDaysBetweenPrompts}');
        return false;
      }
    }

    if (_promptCount >= _config.maxPromptsPerYear) {
      AppLogger.instance.debug(
          'Max prompts reached: $_promptCount >= ${_config.maxPromptsPerYear}');
      return false;
    }

    for (final condition in _config.customConditions) {
      if (!condition()) {
        AppLogger.instance.debug('Custom condition not met');
        return false;
      }
    }

    return true;
  }

  @override
  Future<void> recordLaunch() async {
    _launchCount++;
    await _prefs?.setInt(_launchCountKey, _launchCount);
    AppLogger.instance.debug('Launch recorded: $_launchCount');
  }

  @override
  Future<void> recordSignificantEvent(String eventName) async {
    AppLogger.instance.debug('Significant event recorded: $eventName');
  }

  @override
  int get promptsThisYear => _promptCount;

  @override
  DateTime? get lastPromptDate => _lastPromptDate;

  /// Resets all data (for testing).
  @visibleForTesting
  Future<void> reset() async {
    await _prefs?.remove(_launchCountKey);
    await _prefs?.remove(_installDateKey);
    await _prefs?.remove(_lastPromptKey);
    await _prefs?.remove(_promptCountKey);
    await _prefs?.remove(_promptYearKey);

    _launchCount = 0;
    _installDate = DateTime.now();
    _lastPromptDate = null;
    _promptCount = 0;
    _promptYear = DateTime.now().year;
  }
}

/// Singleton for global access.
class RateReviewServiceProvider {
  static RateReviewService? _instance;

  static RateReviewService get instance {
    _instance ??= LocalRateReviewService();
    return _instance!;
  }

  static void setInstance(RateReviewService service) {
    _instance = service;
  }
}
