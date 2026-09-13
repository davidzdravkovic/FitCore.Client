import 'package:dio/dio.dart';
import 'package:fitcore_client/core/api/api_exception.dart';

/// Maps transport / Dio failures to short [ApiException] messages for the UI.
abstract final class DioExceptionMapper {
  static ApiException toApiException(DioException exception) {
    final status = exception.response?.statusCode;

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          'Request timed out. Try again.',
          statusCode: status,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Cannot reach the server. Check your connection.',
          statusCode: status,
        );
      case DioExceptionType.cancel:
        return ApiException(
          'Request cancelled',
          statusCode: status,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          'Secure connection failed.',
          statusCode: status,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          messageFromBody(exception.response?.data) ?? 'Request failed',
          statusCode: status,
        );
      case DioExceptionType.unknown:
        if (exception.response == null) {
          return ApiException(
            'Cannot reach the server. Check your connection.',
            statusCode: status,
          );
        }
        return ApiException(
          messageFromBody(exception.response?.data) ?? 'Request failed',
          statusCode: status,
        );
    }
  }

  static String? messageFromBody(dynamic data) {
    if (data is! Map) return null;

    final message = data['message'] ?? data['title'];
    if (message is String && message.isNotEmpty) return message;

    final errors = data['errors'];
    if (errors is Map) {
      final parts = <String>[];
      for (final value in errors.values) {
        if (value is List) {
          parts.addAll(value.map((e) => '$e'));
        } else if (value != null) {
          parts.add('$value');
        }
      }
      if (parts.isNotEmpty) return parts.join(' ');
    }

    return null;
  }
}
