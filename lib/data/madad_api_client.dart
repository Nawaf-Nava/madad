import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MadadApiException implements Exception {
  const MadadApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

/// HTTP client for endpoints implemented by the existing MADAD Express API.
/// The base URL is configuration only; never put credentials in the URL or app.
class MadadApiClient {
  MadadApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = Uri.parse(
          baseUrl ??
              const String.fromEnvironment(
                'MADAD_API_BASE_URL',
                defaultValue:
                    kIsWeb ? 'http://127.0.0.1:5000' : 'http://10.0.2.2:5000',
              ),
        ) {
    if (!_baseUrl.hasScheme ||
        _baseUrl.host.isEmpty ||
        _baseUrl.userInfo.isNotEmpty ||
        !_baseUrl.hasAuthority) {
      throw ArgumentError.value(baseUrl, 'baseUrl',
          'Must be an absolute URL without embedded credentials.');
    }
  }

  final http.Client _client;
  final Uri _baseUrl;

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) =>
      _post('/api/auth/login', {'phone': phone, 'password': password});

  Future<Map<String, dynamic>> register({
    required String phone,
    required String fullName,
    required String password,
    String? email,
  }) {
    final body = <String, dynamic>{
      'phone': phone,
      'fullName': fullName,
      'password': password,
    };
    if (email != null && email.trim().isNotEmpty) body['email'] = email.trim();
    return _post('/api/auth/register', body);
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) =>
      _post('/api/auth/refresh', {'refreshToken': refreshToken});

  Future<void> logout(String refreshToken) async {
    await _request('POST', '/api/auth/logout',
        body: {'refreshToken': refreshToken}, allowNoContent: true);
  }

  Future<Map<String, dynamic>> logoutAll(String accessToken) =>
      _requestObject('POST', '/api/auth/logout-all', token: accessToken);

  Future<Map<String, dynamic>> getProfile(String accessToken) =>
      _getObject('/api/auth/profile', accessToken);

  Future<Map<String, dynamic>> updateProfile(
          String accessToken, Map<String, dynamic> body) =>
      _requestObject('PATCH', '/api/auth/profile',
          token: accessToken, body: body);

  Future<List<Map<String, dynamic>>> getWallets(String accessToken) =>
      _getList('/api/wallet/', accessToken);

  Future<Map<String, dynamic>> getWallet(String accessToken, String walletId) =>
      _getObject('/api/wallet/${Uri.encodeComponent(walletId)}', accessToken);

  Future<List<Map<String, dynamic>>> getTransactions(String accessToken) =>
      _getList('/api/wallet/transactions', accessToken);

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) =>
      _requestObject('POST', path, body: body);

  Future<Map<String, dynamic>> _getObject(String path, String token) =>
      _requestObject('GET', path, token: token);

  Future<List<Map<String, dynamic>>> _getList(String path, String token) async {
    final result = await _request('GET', path, token: token);
    if (result is! List) {
      throw const MadadApiException('استجابة الخادم غير صالحة.');
    }
    return result
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _requestObject(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final result = await _request(method, path, body: body, token: token);
    if (result is! Map) {
      throw const MadadApiException('استجابة الخادم غير صالحة.');
    }
    return Map<String, dynamic>.from(result);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
    bool allowNoContent = false,
  }) async {
    final uri = _baseUrl.resolve(path);
    final request = http.Request(method, uri)
      ..headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    try {
      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed)
          .timeout(const Duration(seconds: 15));
      if (allowNoContent && response.statusCode == 204) return null;

      dynamic decoded;
      if (response.body.isNotEmpty) {
        try {
          decoded = jsonDecode(response.body);
        } on FormatException {
          throw const MadadApiException('أعاد الخادم استجابة غير مفهومة.');
        }
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map && decoded['error'] is String
            ? decoded['error'] as String
            : 'تعذر إكمال الطلب (${response.statusCode}).';
        final code = decoded is Map && decoded['code'] is String
            ? decoded['code'] as String
            : null;
        throw MadadApiException(message,
            statusCode: response.statusCode, code: code);
      }
      return decoded;
    } on MadadApiException {
      rethrow;
    } on TimeoutException {
      throw const MadadApiException(
          'انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.');
    } on http.ClientException {
      throw const MadadApiException(
          'تعذر الاتصال بخادم مَدَد. تحقق من العنوان والاتصال.');
    } on Exception {
      throw const MadadApiException(
          'تعذر الاتصال بخادم مَدَد. تحقق من العنوان والاتصال.');
    }
  }

  void close() => _client.close();
}
