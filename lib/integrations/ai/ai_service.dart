import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';

/// AI service abstraction for generative AI integrations.
abstract interface class AIService {
  /// Generate text response from prompt.
  Future<Result<String>> generateText(String prompt);

  /// Generate streaming text response.
  Stream<Result<String>> generateTextStream(String prompt);

  /// Generate structured response with JSON parsing.
  Future<Result<T>> generateStructured<T>(
    String prompt,
    T Function(Map<String, dynamic>) fromJson,
  );

  /// Check if service is available.
  Future<bool> isAvailable();
}

/// AI error types for mapping to AppFailure.
enum AIErrorType {
  invalidApiKey,
  quotaExceeded,
  contentBlocked,
  networkError,
  parseError,
  unknown,
}

/// Maps AI errors to AppFailure hierarchy.
AppFailure mapAIError(AIErrorType type, [String? message]) {
  return switch (type) {
    AIErrorType.invalidApiKey => AuthFailure(
        message ?? 'Invalid AI API key',
        code: 'AI_INVALID_KEY',
      ),
    AIErrorType.quotaExceeded => RateLimitFailure(
        message ?? 'AI quota exceeded',
        code: 'AI_QUOTA_EXCEEDED',
      ),
    AIErrorType.contentBlocked => ValidationFailure(
        message ?? 'Content blocked by safety filters',
        code: 'AI_CONTENT_BLOCKED',
      ),
    AIErrorType.networkError => NetworkFailure(
        message ?? 'AI service unreachable',
        code: 'AI_NETWORK_ERROR',
      ),
    AIErrorType.parseError => ValidationFailure(
        message ?? 'Failed to parse AI response',
        code: 'AI_PARSE_ERROR',
      ),
    AIErrorType.unknown => UnexpectedFailure(
        message ?? 'Unknown AI error',
        code: 'AI_UNKNOWN_ERROR',
      ),
  };
}

/// Mock AI service for development/testing.
class MockAIService implements AIService {
  @override
  Future<Result<String>> generateText(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Success('Mock response for: $prompt');
  }

  @override
  Stream<Result<String>> generateTextStream(String prompt) async* {
    final words = 'Mock streaming response for: $prompt'.split(' ');
    for (final word in words) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield Success('$word ');
    }
  }

  @override
  Future<Result<T>> generateStructured<T>(
    String prompt,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final mockData = <String, dynamic>{'mock': true, 'prompt': prompt};
      return Success(fromJson(mockData));
    } catch (e) {
      return Failure(mapAIError(AIErrorType.parseError, e.toString()));
    }
  }

  @override
  Future<bool> isAvailable() async => true;
}

// Uncomment when using google_generative_ai package:
// class GeminiAIService implements AIService {
//   final GenerativeModel _model;
//
//   GeminiAIService(String apiKey)
//       : _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
//
//   @override
//   Future<Result<String>> generateText(String prompt) async {
//     try {
//       final response = await _model.generateContent([Content.text(prompt)]);
//       return Success(response.text ?? '');
//     } catch (e) {
//       return Failure(_mapError(e));
//     }
//   }
//
//   AppFailure _mapError(dynamic e) {
//     final message = e.toString();
//     if (message.contains('API key')) {
//       return mapAIError(AIErrorType.invalidApiKey, message);
//     }
//     if (message.contains('quota')) {
//       return mapAIError(AIErrorType.quotaExceeded, message);
//     }
//     return mapAIError(AIErrorType.unknown, message);
//   }
// }
