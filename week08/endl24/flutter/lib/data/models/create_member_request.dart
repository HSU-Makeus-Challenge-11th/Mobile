class CreateMemberRequest {
  const CreateMemberRequest({
    required this.email,
    required this.password,
    required this.nickname,
  });

  final String email;
  final String password;
  final String nickname;

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password, // 비밀번호는 입력 그대로 보냅니다.
        'nickname': nickname.trim(),
      };
}