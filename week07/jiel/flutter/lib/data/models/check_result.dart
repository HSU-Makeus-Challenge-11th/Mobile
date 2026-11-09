/// v6 닉네임·이메일 중복 확인 **성공** 응답.
/// 성공 시에는 공통 Wrapper 없이 응답 body가 곧 이 모델이다(오류만 CommonResponse 형식). 예: { "available": true }
class CheckResult {
  const CheckResult({required this.available});

  final bool available;

  factory CheckResult.fromJson(Map<String, dynamic> json) {
    return CheckResult(available: json['available'] as bool);
  }
}
