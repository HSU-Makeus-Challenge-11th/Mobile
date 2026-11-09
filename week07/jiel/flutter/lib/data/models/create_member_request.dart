/// POST /v6/members 요청 body. Dart 객체 → 요청 JSON 방향(toJson)만 가진다.
///
/// 회원가입 제약(서버 기준):
/// - email: 올바른 이메일 형식
/// - nickname: 2~12자
/// - password: 8자 이상, 소문자·대문자·숫자·!@#$%^&* 특수문자를 각각 하나 이상 포함
///
/// 클라이언트 검증은 빠른 안내용일 뿐 서버 검증을 대체하지 않는다.
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
        // 비밀번호는 사용자가 입력한 문자 자체가 의미 있으므로 trim()으로 값을 바꾸지 않는다.
        // 앞뒤 공백을 금지할지는 Form validator가 명확히 처리한다.
        'password': password,
        'nickname': nickname.trim(),
      };
}
