import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:madad/app/madad_app.dart';
import 'package:madad/data/madad_api_client.dart';
import 'package:madad/data/session_storage.dart';

MadadApp createTestApp() => MadadApp(
      apiClient: MadadApiClient(
        baseUrl: 'https://madad.test',
        client: MockClient(_testApi),
      ),
      sessionStorage: _MemorySessionStorage(),
    );

Future<http.Response> _testApi(http.Request request) async {
  final path = request.url.path;
  if (path == '/api/auth/login' || path == '/api/auth/register') {
    return _json(200, {
      'accessToken': 'widget-test-access-token',
      'refreshToken': 'widget-test-refresh-token',
      'user': {
        'id': 'widget-test-user',
        'phone': '771234567',
        'fullName': 'Widget Test User',
        'email': null,
        'wallets': [],
      },
    });
  }
  if (path == '/api/auth/refresh') {
    return _json(200, {
      'accessToken': 'widget-test-refreshed-access-token',
      'refreshToken': 'widget-test-refreshed-refresh-token',
      'user': {
        'id': 'widget-test-user',
        'phone': '771234567',
        'fullName': 'Widget Test User',
        'email': null,
        'wallets': [],
      },
    });
  }
  if (path == '/api/auth/logout') return http.Response('', 204);
  if (path == '/api/auth/logout-all') {
    return _json(200, {'revokedSessions': 1});
  }
  if (path == '/api/auth/profile') {
    if (request.method == 'PATCH') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return _json(200, {
        'id': 'widget-test-user',
        'phone': '771234567',
        'fullName': body['fullName'] ?? 'Widget Test User',
        'email': body['email'],
        'profile': null,
        'wallets': [],
      });
    }
    return _json(200, {
      'id': 'widget-test-user',
      'phone': '771234567',
      'fullName': 'Widget Test User',
      'email': null,
      'profile': null,
      'wallets': [],
    });
  }
  if (path == '/api/wallet/') return _json(200, <Object>[]);
  if (path == '/api/wallet/transactions') return _json(200, <Object>[]);
  return _json(404, {'error': 'Not found', 'code': 'NOT_FOUND'});
}

http.Response _json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: const {'content-type': 'application/json'},
    );

class _MemorySessionStorage implements SessionStorage {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
