class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final access = json['accessToken'];
    final refresh = json['refreshToken'];
    final userData = json['user'];
    if (access is! String ||
        access.isEmpty ||
        refresh is! String ||
        refresh.isEmpty ||
        userData is! Map) {
      throw const FormatException('Invalid authentication response.');
    }
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      user: Map<String, dynamic>.from(userData),
    );
  }
}
