class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory ApiException.network() => const ApiException(
        message: 'Network connection failed. Please check your network.',
      );

  factory ApiException.timeout() => const ApiException(
        message: 'Request timed out. Please try again.',
      );

  factory ApiException.server(int statusCode) => ApiException(
        message: 'Server error ($statusCode)',
        statusCode: statusCode,
      );

  factory ApiException.parse(String detail) => ApiException(
        message: 'Failed to parse response: $detail',
      );

  factory ApiException.unauthorized() => const ApiException(
        message: 'Please login first.',
        statusCode: 401,
      );

  factory ApiException.banned() => const ApiException(
        message: 'Your IP has been temporarily banned.',
        statusCode: 509,
      );

  @override
  String toString() => 'ApiException: $message';
}
