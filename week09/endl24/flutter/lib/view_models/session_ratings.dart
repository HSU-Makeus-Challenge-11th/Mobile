import 'package:flutter/foundation.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/view_models/auth_view_model.dart';

/// 이번 로그인 세션에서 등록한 평점을 메모리에 보관합니다.
///
/// v7에는 토큰으로 "내 평점 전체"를 받는 API가 없고, 로그인 응답에 memberId도 없습니다.
/// 그래서 등록 응답으로 받은 평점만 모아 두고 그 안에서 수정·삭제합니다.
/// 로그아웃·만료·다른 계정 로그인으로 세션 번호가 바뀌면 비웁니다.
class SessionRatings extends ChangeNotifier {
  SessionRatings(this._auth) : _sessionVersion = _auth.sessionVersion {
    _auth.addListener(_onAuthChanged);
  }

  final AuthViewModel _auth;
  int _sessionVersion;
  final List<RatingWithMovie> _items = [];

  List<RatingWithMovie> get items => List.unmodifiable(_items);

  void _onAuthChanged() {
    if (_auth.sessionVersion == _sessionVersion) return;
    _sessionVersion = _auth.sessionVersion;
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  /// 요청을 보낼 때의 세션과 지금 세션이 같을 때만 반영합니다.
  bool _isCurrent(int sessionVersion) => sessionVersion == _sessionVersion;

  void add(RatingWithMovie entry, {required int sessionVersion}) {
    if (!_isCurrent(sessionVersion)) return;
    _items
      ..removeWhere((item) => item.rating.ratingId == entry.rating.ratingId)
      ..insert(0, entry); // 최신 평점을 맨 위에 둡니다.
    notifyListeners();
  }

  void replace(RatingDto updated, {required int sessionVersion}) {
    if (!_isCurrent(sessionVersion)) return;
    final index = _items.indexWhere(
      (item) => item.rating.ratingId == updated.ratingId,
    );
    if (index < 0) return;
    _items[index] = RatingWithMovie(
      rating: updated,
      movie: _items[index].movie,
    );
    notifyListeners();
  }

  void remove(int ratingId, {required int sessionVersion}) {
    if (!_isCurrent(sessionVersion)) return;
    final before = _items.length;
    _items.removeWhere((item) => item.rating.ratingId == ratingId);
    if (_items.length != before) notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
