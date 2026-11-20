import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/view_models/favorite_detail_view_model.dart';

import 'support/fake_favorite_api.dart';

void main() {
  late FakeFavoriteApi api;
  late SessionGuard guard;
  late int expiredCalls;

  FavoriteDetailViewModel create({String account = 'a@umc.com'}) =>
      FavoriteDetailViewModel(
        movieId: 550,
        favoriteApi: api,
        sessionGuard: guard,
        accountId: account,
        onSessionExpired: () async => expiredCalls++,
      );

  setUp(() {
    api = FakeFavoriteApi();
    guard = SessionGuard()..startSession('a@umc.com');
    expiredCalls = 0;
  });

  test('load reflects the server value', () async {
    api.movieIds.add(550);
    final vm = create();
    await vm.load();
    expect(vm.hasLoadedStatus, isTrue);
    expect(vm.isFavorite, isTrue);
  });

  test('toggle changes the icon only after the server succeeds', () async {
    final vm = create();
    await vm.load();
    api.gate = Completer<void>();
    final pending = vm.toggle();
    expect(vm.isSaving, isTrue);
    expect(vm.isFavorite, isFalse);
    await vm.toggle(); // 저장 중 두 번째 탭은 무시한다
    api.gate!.complete();
    await pending;
    expect(api.addCalls, 1);
    expect(vm.isFavorite, isTrue);
    expect(vm.isSaving, isFalse);

    await vm.toggle();
    expect(vm.isFavorite, isFalse);
    expect(api.movieIds, isEmpty);
  });

  test('a failure keeps the previous icon and shows the W9 message', () async {
    final vm = create();
    await vm.load();
    api.writeError = DioException(requestOptions: RequestOptions());
    await vm.toggle();
    expect(vm.isFavorite, isFalse);
    expect(vm.errorMessage, '저장하지 못했습니다. 다시 시도해 주세요.');
  });

  test('409 and 404 resync with GET instead of posting again', () async {
    final vm = create();
    await vm.load(); // false
    api.movieIds.add(550); // 다른 기기에서 이미 등록됨
    api.writeError = favoriteError('/v8/favorites', 409, 'FAVORITE409_1');
    await vm.toggle();
    expect(api.addCalls, 1);
    expect(vm.isFavorite, isTrue);
    expect(vm.errorMessage, isNull);

    api.movieIds.clear(); // 이미 해제됨
    api.writeError = favoriteError('/v8/favorites/550', 404, 'FAVORITE404_1');
    await vm.toggle();
    expect(vm.isFavorite, isFalse);
    expect(vm.errorMessage, isNull);
  });

  test('a load failure leaves the button disabled until retried', () async {
    api.checkError = DioException(requestOptions: RequestOptions());
    final vm = create();
    await vm.load();
    expect(vm.hasLoadedStatus, isFalse);
    expect(vm.errorMessage, isNotNull);
    await vm.toggle();
    expect(api.addCalls, 0);
    api.checkError = null;
    await vm.load();
    expect(vm.hasLoadedStatus, isTrue);
  });

  test('session expiry codes clear the current session once', () async {
    api.checkError = favoriteError('/v8/favorites/550', 401, 'AUTH401_4');
    final vm = create();
    await vm.load();
    expect(expiredCalls, 1);
  });

  test('a late response from an old session is ignored', () async {
    final vm = create();
    await vm.load();
    api.gate = Completer<void>();
    api.writeError = favoriteError('/v8/favorites', 401, 'AUTH401_3');
    final pending = vm.toggle();
    guard.startSession('b@umc.com'); // 그 사이 다른 계정으로 로그인
    api.gate!.complete();
    await pending;
    expect(expiredCalls, 0); // 이전 계정의 401로 현재 계정을 로그아웃시키지 않는다
    expect(vm.isSaving, isTrue); // 이전 세션 ViewModel은 더 이상 갱신하지 않는다
  });

  test('nothing is requested for a stale account', () async {
    final vm = create(account: 'b@umc.com');
    await vm.load();
    expect(vm.isLoading, isFalse);
    expect(vm.hasLoadedStatus, isFalse);
  });
}
