import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? error;
  final Map<String, String>? fieldErrors;
  final bool isNetworkError;
  final bool isTimeout;

  const ApiException({
    required this.message,
    this.statusCode,
    this.error,
    this.fieldErrors,
    this.isNetworkError = false,
    this.isTimeout = false,
  });

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          message:
              'Connection timed out. Please check your network and try again.',
          isTimeout: true,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Unable to connect to server. Please verify the backend is running.',
          isNetworkError: true,
        );
      case DioExceptionType.badResponse:
        final response = e.response;
        if (response != null && response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final msg =
              data['message'] as String? ??
              'Request failed with status ${response.statusCode}';
          final err = data['error'] as String?;
          final rawFieldErrors = data['fieldErrors'];
          Map<String, String>? fieldErrors;
          if (rawFieldErrors is Map) {
            fieldErrors = rawFieldErrors.map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            );
          }
          return ApiException(
            message: msg,
            statusCode: response.statusCode,
            error: err,
            fieldErrors: fieldErrors,
          );
        }
        return ApiException(
          message:
              'Server error occurred (${e.response?.statusCode ?? 'unknown'}).',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'Request was cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiException(message: 'Invalid server SSL certificate.');
      case DioExceptionType.unknown:
        return ApiException(
          message: e.message ?? 'An unexpected network error occurred.',
          isNetworkError: true,
        );
    }
  }

  @override
  String toString() => message;
}
