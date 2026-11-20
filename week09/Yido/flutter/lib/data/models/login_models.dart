class LoginRequest {
  const LoginRequest({required this.email, required this.password});
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
    'email': email.trim(),
    'password': password,
  };
}

/// 로그인 result에는 memberId가 없다. JWT payload에서 추정하지 않는다
class LoginResult {
  const LoginResult({required this.nickname, required this.accessToken});
  final String nickname;
  final String accessToken;

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
    nickname: json['nickname'] as String,
    accessToken: json['accessToken'] as String,
  );
}
