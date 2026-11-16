import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/edit_profile_view_model.dart';

import 'support/fake_auth_services.dart';
import 'support/fake_token_storage.dart';

void main() {
  late FakeMemberApiService memberApi;
  late AuthViewModel auth;
  late EditProfileViewModel viewModel;

  setUp(() async {
    memberApi = FakeMemberApiService();
    auth = AuthViewModel(FakeAuthApiService(), memberApi, FakeTokenStorage());
    await auth.login('a@umc.com', 'Umc1234!');
    await auth.loadMember();
    viewModel = EditProfileViewModel(memberApi, auth);
  });

  test('2~12 characters are checked before any request', () async {
    for (final value in ['가', ' 가 ', '가' * 13]) {
      expect(await viewModel.save(value), isFalse);
      expect(viewModel.nicknameError, '닉네임은 2~12자로 입력해 주세요.');
    }
    expect(memberApi.updates, isEmpty);
  });

  test('the current nickname completes without a request', () async {
    expect(await viewModel.save(' 시네필A '), isTrue);
    expect(memberApi.updates, isEmpty);
  });

  test('success replaces the member for my page', () async {
    expect(await viewModel.save(' 새닉네임 '), isTrue);
    expect(memberApi.updates, ['새닉네임']);
    expect(auth.member!.nickname, '새닉네임');
  });

  test('409 shows under the field and keeps the session', () async {
    memberApi.error = apiError('/v7/members/me', 409, 'MEMBER409_1');
    expect(await viewModel.save('영화광B'), isFalse);
    expect(viewModel.nicknameError, '이미 사용 중인 닉네임이에요.');
    expect(viewModel.message, isNull);
    expect(auth.member!.nickname, '시네필A');
    expect(auth.status, AuthStatus.signedIn);
  });

  test('a network failure goes to the snackbar without logging out', () async {
    memberApi.error = networkError('/v7/members/me');
    expect(await viewModel.save('새닉네임'), isFalse);
    expect(viewModel.nicknameError, isNull);
    expect(viewModel.message, contains('네트워크'));
    expect(auth.status, AuthStatus.signedIn);
  });

  test('an expired token ends the session', () async {
    memberApi.error = apiError('/v7/members/me', 401, 'AUTH401_4');
    expect(await viewModel.save('새닉네임'), isFalse);
    expect(auth.status, AuthStatus.signedOut);
    expect(auth.sessionExpired, isTrue);
  });

  test('a second tap while saving sends nothing', () async {
    memberApi.gate = Completer();
    final first = viewModel.save('새닉네임');
    expect(viewModel.status, EditProfileStatus.saving);
    expect(await viewModel.save('새닉네임'), isFalse);
    memberApi.gate!.complete();
    expect(await first, isTrue);
    expect(memberApi.updates, hasLength(1));
  });

  test('an answer after logout is ignored', () async {
    memberApi.gate = Completer();
    final saving = viewModel.save('새닉네임');
    await auth.logout();
    memberApi.gate!.complete();
    expect(await saving, isFalse);
    expect(auth.member, isNull);
  });
}
