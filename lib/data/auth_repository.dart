import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_session.dart';
import 'madad_api_client.dart';
import 'session_storage.dart';

class AuthRepository {
  AuthRepository({
    required MadadApiClient api,
    FlutterSecureStorage? storage,
  })  : _api = api,
        _storage =
            _FlutterSessionStorage(storage ?? const FlutterSecureStorage());

  AuthRepository.withStorage({
    required MadadApiClient api,
    required SessionStorage storage,
  })  : _api = api,
        _storage = storage;

  static const _accessTokenKey = 'madad.auth.access';
  static const _refreshTokenKey = 'madad.auth.refresh';
  static const _userKey = 'madad.auth.user';

  final MadadApiClient _api;
  final SessionStorage _storage;

  Future<AuthSession?> restoreSession() async {
    final refreshToken = await _storage.read(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await _api.refresh(refreshToken);
      final session = AuthSession.fromJson(response);
      await _save(session);
      return session;
    } on MadadApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await clearLocalSession();
        return null;
      }
      rethrow;
    }
  }

  Future<AuthSession> register({
    required String phone,
    required String fullName,
    required String password,
    String? email,
  }) async {
    final response = await _api.register(
      phone: phone,
      fullName: fullName,
      password: password,
      email: email,
    );
    final session = AuthSession.fromJson(response);
    await _save(session);
    return session;
  }

  Future<AuthSession> login({
    required String phone,
    required String password,
  }) async {
    final response = await _api.login(phone: phone, password: password);
    final session = AuthSession.fromJson(response);
    await _save(session);
    return session;
  }

  Future<Map<String, dynamic>> getProfile() async {
    return _withAccess((token) => _api.getProfile(token));
  }

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (email != null) body['email'] = email;
    return _withAccess((token) => _api.updateProfile(token, body));
  }

  Future<List<Map<String, dynamic>>> getWallets() =>
      _withAccess(_api.getWallets);

  Future<List<Map<String, dynamic>>> getTransactions() =>
      _withAccess(_api.getTransactions);

  Future<void> logout() async {
    final refreshToken = await _storage.read(_refreshTokenKey);
    if (refreshToken != null) {
      try {
        await _api.logout(refreshToken);
      } on MadadApiException catch (error) {
        if (error.statusCode != 401 && error.statusCode != 403) rethrow;
      } finally {
        await clearLocalSession();
      }
    } else {
      await clearLocalSession();
    }
  }

  Future<int> logoutAll() async {
    final result = await _withAccess(_api.logoutAll);
    await clearLocalSession();
    return (result['revokedSessions'] as num?)?.toInt() ?? 0;
  }

  Future<void> clearLocalSession() async {
    await Future.wait([
      _storage.delete(_accessTokenKey),
      _storage.delete(_refreshTokenKey),
      _storage.delete(_userKey),
    ]);
  }

  Future<void> _save(AuthSession session) async {
    await Future.wait([
      _storage.write(_accessTokenKey, session.accessToken),
      _storage.write(_refreshTokenKey, session.refreshToken),
      _storage.write(_userKey, jsonEncode(session.user)),
    ]);
  }

  Future<T> _withAccess<T>(
      Future<T> Function(String accessToken) request) async {
    var accessToken = await _storage.read(_accessTokenKey);
    if (accessToken == null || accessToken.isEmpty) {
      throw const MadadApiException('سجّل الدخول للمتابعة.', statusCode: 401);
    }
    try {
      return await request(accessToken);
    } on MadadApiException catch (error) {
      if (error.statusCode != 401 && error.statusCode != 403) rethrow;
      final refreshToken = await _storage.read(_refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) rethrow;
      final refreshed = AuthSession.fromJson(await _api.refresh(refreshToken));
      await _save(refreshed);
      accessToken = refreshed.accessToken;
      return request(accessToken);
    }
  }
}

class _FlutterSessionStorage implements SessionStorage {
  const _FlutterSessionStorage(this.storage);

  final FlutterSecureStorage storage;

  @override
  Future<String?> read(String key) => storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => storage.delete(key: key);
}
