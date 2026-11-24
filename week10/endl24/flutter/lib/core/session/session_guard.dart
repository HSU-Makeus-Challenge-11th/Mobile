/// "지금 도착한 응답이 현재 로그인 세션의 것인지"를 판정합니다.
///
/// 요청을 보낼 때 generation과 계정(email)을 기억해 두고,
/// 응답이 도착했을 때 isCurrent(...)가 true일 때만 화면 상태에 반영합니다.
/// 로그아웃·계정 전환 뒤 늦게 도착한 이전 계정의 응답을 버리는 용도입니다.
class SessionGuard {
  int _generation = 0;
  String? _accountId;

  int get generation => _generation;
  String? get accountId => _accountId;

  /// 검증된 새 세션을 시작합니다. AuthSessionBridge만 호출합니다.
  /// 화면이나 ViewModel에서 호출하지 않고, build마다 호출하지도 않습니다.
  int startSession(String accountId) {
    _accountId = accountId;
    return ++_generation; // 같은 계정이라도 다시 로그인하면 새 세션입니다.
  }

  /// 현재 세션을 끝냅니다. 이전 generation으로 보낸 요청의 응답은 모두 무시됩니다.
  void invalidate() {
    _accountId = null;
    _generation++;
  }

  bool isCurrent(int generation, String accountId) =>
      _generation == generation && _accountId == accountId;
}
