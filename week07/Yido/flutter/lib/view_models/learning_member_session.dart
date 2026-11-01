import 'package:flutter/foundation.dart';

/// 회원가입 결과의 memberId를 메모리에 보관한다. 이 값을 안다고 인증된 것은 아니다.
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
