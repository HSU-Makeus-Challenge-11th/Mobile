import 'package:flutter/foundation.dart';

/// 회원가입으로 받은 memberId를 앱 전체에서 함께 쓰는 학습용 상태입니다.
/// 로그인 인증이 아니며, 앱을 재시작하면 사라집니다.
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
