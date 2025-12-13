import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// Clipboard service configuration.
class ClipboardConfig {
  const ClipboardConfig({
    this.sensitiveDataTimeout = const Duration(seconds: 30),
    this.showCopyConfirmation = true,
  });
  final Duration sensitiveDataTimeout;
  final bool showCopyConfirmation;
}

/// Abstract clipboard service interface.
abstract interface class ClipboardService {
  /// Copies text to clipboard.
  Future<Result<void>> copyText(String text);

  /// Copies sensitive text with auto-clear.
  Future<Result<void>> copySensitive(String text);

  /// Gets text from clipboard.
  Future<Result<String?>> getText();

  /// Checks if clipboard has text.
  Future<bool> hasText();

  /// Clears the clipboard.
  Future<void> clear();
}

/// Clipboard service implementation.
class ClipboardServiceImpl implements ClipboardService {
  ClipboardServiceImpl({this.config = const ClipboardConfig()});
  final ClipboardConfig config;
  Timer? _clearTimer;

  @override
  Future<Result<void>> copyText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return const Success(null);
    } on PlatformException catch (e) {
      return Failure(
        UnexpectedFailure('Platform clipboard error: ${e.message}'),
      );
    } on MissingPluginException catch (e) {
      return Failure(
        UnexpectedFailure('Clipboard plugin not available: ${e.message}'),
      );
    } on Object catch (e) {
      return Failure(UnexpectedFailure('Unexpected clipboard error: $e'));
    }
  }

  @override
  Future<Result<void>> copySensitive(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));

      // Cancel any existing timer
      _clearTimer?.cancel();

      // Schedule auto-clear after timeout
      _clearTimer = Timer(config.sensitiveDataTimeout, clear);

      return const Success(null);
    } on PlatformException catch (e) {
      return Failure(
        UnexpectedFailure('Platform clipboard error: ${e.message}'),
      );
    } on MissingPluginException catch (e) {
      return Failure(
        UnexpectedFailure('Clipboard plugin not available: ${e.message}'),
      );
    } on Object catch (e) {
      return Failure(UnexpectedFailure('Unexpected clipboard error: $e'));
    }
  }

  @override
  Future<Result<String?>> getText() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return Success(data?.text);
    } on PlatformException catch (e) {
      return Failure(
        UnexpectedFailure('Platform clipboard error: ${e.message}'),
      );
    } on MissingPluginException catch (e) {
      return Failure(
        UnexpectedFailure('Clipboard plugin not available: ${e.message}'),
      );
    } on Object catch (e) {
      return Failure(UnexpectedFailure('Unexpected clipboard error: $e'));
    }
  }

  @override
  Future<bool> hasText() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text?.isNotEmpty ?? false;
    } on PlatformException catch (_) {
      // Platform clipboard unavailable
      return false;
    } on MissingPluginException catch (_) {
      // Clipboard plugin not available
      return false;
    } on Object catch (_) {
      // Any other error
      return false;
    }
  }

  @override
  Future<void> clear() async {
    _clearTimer?.cancel();
    _clearTimer = null;
    await Clipboard.setData(const ClipboardData(text: ''));
  }

  void dispose() {
    _clearTimer?.cancel();
  }
}

/// Clipboard service factory.
ClipboardService createClipboardService({
  ClipboardConfig config = const ClipboardConfig(),
}) => ClipboardServiceImpl(config: config);
