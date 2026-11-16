/// POST /v7/auth/login 요청 body. 비밀번호는 이 객체로 전송만 하고 어디에도 저장하지 않는다.
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password,
      };
}

/// 로그인 성공 result. v7 계약에는 memberId가 없으므로 추정해서 추가하지 않는다.
class LoginResult {
  const LoginResult({required this.nickname, required this.accessToken});

  final String nickname;
  final String accessToken;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      nickname: json['nickname'] as String,
      accessToken: json['accessToken'] as String,
    );
  }
}
