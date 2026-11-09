import 'package:flutter/foundation.dart';

/// 학습용 "현재 회원" 상태. 회원가입 성공 응답의 memberId를 보관한다.
///
/// - 메모리에만 있으므로 앱을 재시작하면 사라진다.
/// - memberId를 알고 있다는 사실은 인증이 아니다. JWT 주차에는 보호 요청에서 memberId path를 빼고
///   서버가 토큰으로 현재 회원을 식별하도록 바꾼다.
/// - 6주차의 고정 memberId 1을 새 회원의 ID처럼 사용하지 않기 위해 둔다.
class LearningMemberSession extends ChangeNotifier {
  int? memberId;

  void setMemberId(int id) {
    memberId = id;
    notifyListeners();
  }

  void clear() {
    memberId = null;
    notifyListeners();
  }
}
