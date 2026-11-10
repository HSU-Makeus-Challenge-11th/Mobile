/// POST /v6/members 성공(201) 응답의 `result` payload.
/// 공통 응답 `CommonResponse<SignUpResult>`의 result 자리에 들어간다.
///
/// 서버 응답 → Dart 객체 방향(fromJson)만 가진다.
/// 가입 성공 후 `response.result?.memberId`가 null이면 가입 완료로 표시하지 않고 계약 오류로 처리한다.
class SignUpResult {
  const SignUpResult({
    required this.memberId,
    required this.email,
    required this.nickname,
  });

  final int memberId;
  final String email;
  final String nickname;

  factory SignUpResult.fromJson(Map<String, dynamic> json) {
    return SignUpResult(
      memberId: (json['memberId'] as num).toInt(),
      email: json['email'] as String,
      nickname: json['nickname'] as String,
    );
  }
}
