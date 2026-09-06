import 'package:dio/dio.dart';
import 'package:fitcore_client/core/api/api_config.dart';
import 'package:fitcore_client/core/api/api_exception.dart';

typedef JsonParser<T> = T Function(dynamic json);

class ApiClient {
  ApiClient._()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  static final ApiClient instance = ApiClient._();

  final Dio _dio;
  String? _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Future<T> request<T>(
    String path, {
    String method = 'GET',
    Object? data,
    bool useAuth = true,
    required JsonParser<T> parse,
  }) async {
    final hadToken = _accessToken != null && _accessToken!.isNotEmpty;
    final headers = <String, dynamic>{};

    if (useAuth && hadToken) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    if (useAuth && !hadToken) {
    throw ApiException('Not signed in', statusCode: 401);
    }

    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        options: Options(method: method, headers: headers),
      );

      return parse(response.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 401 && useAuth && hadToken) {
        setAccessToken(null);
        throw ApiException('Session expired', statusCode: status);
      }

      throw ApiException(
        _messageFrom(e.response?.data) ?? e.message ?? 'Request failed',
        statusCode: status,
      );
    }
    catch (e) {
    throw ApiException('Invalid response from server');
}
  }

  String? _messageFrom(dynamic data) {
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
