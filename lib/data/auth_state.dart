import 'package:flutter/foundation.dart';

import 'auth_repository.dart';
import 'auth_session.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._repository);

  final AuthRepository _repository;
  AuthSession? _session;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  Future<void> restore() => _run(() async {
        _session = await _repository.restoreSession();
      }, initialize: true);

  Future<void> register({
    required String phone,
    required String fullName,
    required String password,
    String? email,
  }) =>
      _run(() async {
        _session = await _repository.register(
          phone: phone,
          fullName: fullName,
          password: password,
          email: email,
        );
      });

  Future<void> login({required String phone, required String password}) =>
      _run(() async {
        _session = await _repository.login(phone: phone, password: password);
      });

  Future<void> logout() => _run(() async {
        try {
          await _repository.logout();
        } finally {
          _session = null;
        }
      });

  Future<int> logoutAll() async {
    var revoked = 0;
    await _run(() async {
      try {
        revoked = await _repository.logoutAll();
      } finally {
        _session = null;
      }
    });
    return revoked;
  }

  Future<void> _run(Future<void> Function() action,
      {bool initialize = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString();
      if (!initialize) rethrow;
    } finally {
      if (initialize) _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }
}
