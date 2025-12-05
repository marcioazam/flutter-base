import '../errors/failures.dart';
import '../utils/result.dart';

/// GraphQL operation type.
enum GraphQLOperationType { query, mutation, subscription }

/// GraphQL request configuration.
class GraphQLRequest {
  final String document;
  final Map<String, dynamic>? variables;
  final String? operationName;
  final GraphQLOperationType type;

  const GraphQLRequest({
    required this.document,
    this.variables,
    this.operationName,
    this.type = GraphQLOperationType.query,
  });
}

/// GraphQL response wrapper.
class GraphQLResponse<T> {
  final T? data;
  final List<GraphQLError>? errors;
  final Map<String, dynamic>? extensions;

  const GraphQLResponse({
    this.data,
    this.errors,
    this.extensions,
  });

  bool get hasErrors => errors != null && errors!.isNotEmpty;
  bool get hasData => data != null;
}

/// GraphQL error representation.
class GraphQLError {
  final String message;
  final List<dynamic>? path;
  final List<Map<String, dynamic>>? locations;
  final Map<String, dynamic>? extensions;

  const GraphQLError({
    required this.message,
    this.path,
    this.locations,
    this.extensions,
  });

  factory GraphQLError.fromJson(Map<String, dynamic> json) {
    return GraphQLError(
      message: json['message'] as String? ?? 'Unknown error',
      path: json['path'] as List<dynamic>?,
      locations: (json['locations'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>(),
      extensions: json['extensions'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() => 'GraphQLError: $message';
}

/// Abstract GraphQL client interface.
abstract interface class GraphQLClient {
  /// Executes a GraphQL query.
  Future<Result<GraphQLResponse<T>>> query<T>(
    GraphQLRequest request, {
    T Function(Map<String, dynamic>)? parser,
  });

  /// Executes a GraphQL mutation.
  Future<Result<GraphQLResponse<T>>> mutate<T>(
    GraphQLRequest request, {
    T Function(Map<String, dynamic>)? parser,
  });

  /// Subscribes to a GraphQL subscription.
  Stream<Result<GraphQLResponse<T>>> subscribe<T>(
    GraphQLRequest request, {
    T Function(Map<String, dynamic>)? parser,
  });

  /// Clears the cache.
  Future<void> clearCache();

  /// Disposes resources.
  void dispose();
}

/// GraphQL client configuration.
class GraphQLClientConfig {
  final String endpoint;
  final String? wsEndpoint;
  final Map<String, String>? headers;
  final Duration timeout;
  final bool enableCache;

  const GraphQLClientConfig({
    required this.endpoint,
    this.wsEndpoint,
    this.headers,
    this.timeout = const Duration(seconds: 30),
    this.enableCache = true,
  });
}

/// GraphQL client implementation.
/// Note: Requires ferry package for full implementation.
class GraphQLClientImpl implements GraphQLClient {
  final GraphQLClientConfig config;
  final Future<String?> Function()? getToken;

  GraphQLClientImpl({
    required this.config,
    this.getToken,
  });

  @override
  Future<Result<GraphQLResponse<T>>> query<T>(
    GraphQLRequest request, {
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      // Placeholder - requires ferry package
      // final client = _createClient();
      // final response = await client.request(request).first;
      // return Success(GraphQLResponse(data: parser?.call(response.data)));

      return Failure(ServerFailure('GraphQL client not configured'));
    } catch (e) {
      return Failure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<GraphQLResponse<T>>> mutate<T>(
    GraphQLRequest request, {
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      // Placeholder - requires ferry package
      return Failure(ServerFailure('GraphQL client not configured'));
    } catch (e) {
      return Failure(NetworkFailure(e.toString()));
    }
  }

  @override
  Stream<Result<GraphQLResponse<T>>> subscribe<T>(
    GraphQLRequest request, {
    T Function(Map<String, dynamic>)? parser,
  }) async* {
    // Placeholder - requires ferry package
    yield Failure(ServerFailure('GraphQL subscriptions not configured'));
  }

  @override
  Future<void> clearCache() async {
    // Placeholder - requires ferry package
  }

  @override
  void dispose() {
    // Placeholder - requires ferry package
  }
}

/// Generic GraphQL repository base class.
abstract class GraphQLRepository<T> {
  final GraphQLClient client;
  final T Function(Map<String, dynamic>) fromJson;

  GraphQLRepository({
    required this.client,
    required this.fromJson,
  });

  /// Executes a query and parses the result.
  Future<Result<T>> executeQuery(GraphQLRequest request) async {
    final response = await client.query<T>(request, parser: fromJson);
    return response.flatMap((r) {
      if (r.hasErrors) {
        return Failure(ServerFailure(r.errors!.first.message));
      }
      if (r.data == null) {
        return Failure(ServerFailure('No data returned'));
      }
      return Success(r.data as T);
    });
  }

  /// Executes a mutation and parses the result.
  Future<Result<T>> executeMutation(GraphQLRequest request) async {
    final response = await client.mutate<T>(request, parser: fromJson);
    return response.flatMap((r) {
      if (r.hasErrors) {
        return Failure(ServerFailure(r.errors!.first.message));
      }
      if (r.data == null) {
        return Failure(ServerFailure('No data returned'));
      }
      return Success(r.data as T);
    });
  }

  /// Subscribes and streams parsed results.
  Stream<Result<T>> executeSubscription(GraphQLRequest request) {
    return client.subscribe<T>(request, parser: fromJson).map((response) {
      return response.flatMap((r) {
        if (r.hasErrors) {
          return Failure(ServerFailure(r.errors!.first.message));
        }
        if (r.data == null) {
          return Failure(ServerFailure('No data returned'));
        }
        return Success(r.data as T);
      });
    });
  }
}
