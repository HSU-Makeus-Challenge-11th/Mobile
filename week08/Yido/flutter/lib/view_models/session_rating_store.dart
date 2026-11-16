import 'package:flutter/foundation.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/view_models/auth_view_model.dart';

/// v7에는 토큰 기반 내 평점 목록 GET이 없다. 이번 로그인 세션에서 등록한 평점만 보관한다.
/// 로그인·로그아웃·만료로 세션이 바뀌면 이전 회원의 평점을 비운다
class SessionRatingStore extends ChangeNotifier {
  SessionRatingStore(this._auth) : _version = _auth.sessionVersion {
    _auth.addListener(_onAuthChanged);
  }

  final AuthViewModel _auth;
  int _version;
  List<RatingDto> _ratings = const [];

  /// 최근에 등록한 평점이 먼저 온다
  List<RatingDto> get ratings => _ratings;

  /// 요청을 보낸 세션이 아직 현재 세션인지 확인할 때 쓴다
  int get version => _version;

  void _onAuthChanged() {
    if (_auth.sessionVersion == _version) return;
    _version = _auth.sessionVersion;
    if (_ratings.isEmpty) return;
    _ratings = const [];
    notifyListeners();
  }

  void put(RatingDto rating, {required int version}) {
    if (version != _version) return; // 이전 세션에서 늦게 도착한 응답
    _ratings = [
      rating,
      for (final r in _ratings)
        if (r.ratingId != rating.ratingId) r,
    ];
    notifyListeners();
  }

  void replace(RatingDto rating, {required int version}) {
    if (version != _version) return;
    _ratings = [
      for (final r in _ratings) r.ratingId == rating.ratingId ? rating : r,
    ];
    notifyListeners();
  }

  void remove(int ratingId, {required int version}) {
    if (version != _version) return;
    _ratings = [
      for (final r in _ratings)
        if (r.ratingId != ratingId) r,
    ];
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
