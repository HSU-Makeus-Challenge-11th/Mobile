import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:movielog/view_models/submit_status.dart';

import 'support/fake_member_services.dart';

void main() {
  late FakeSignUpService service;
  late SignUpViewModel viewModel;

  setUp(() {
    service = FakeSignUpService(duplicated: {'영화광', 'movie@umc.com'});
    viewModel = SignUpViewModel(service);
  });

  test('available and duplicated answers set different states', () async {
    viewModel.onNicknameChanged('무비러버');
    await viewModel.checkNickname('무비러버');
    expect(viewModel.nicknameCheckStatus, CheckStatus.available);
    expect(viewModel.nicknameErrorText, isNull);

    viewModel.onNicknameChanged('영화광');
    await viewModel.checkNickname('영화광');
    expect(viewModel.nicknameCheckStatus, CheckStatus.duplicated);
    expect(viewModel.nicknameErrorText, '이미 사용 중인 닉네임입니다.');
    expect(viewModel.canCheckNickname, isFalse);
  });

  test('communication failure differs from a duplicate answer', () async {
    service.fail = true;
    viewModel.onEmailChanged('new@umc.com');
    await viewModel.checkEmail('new@umc.com');
    expect(viewModel.emailCheckStatus, CheckStatus.error);
    expect(viewModel.emailErrorText, '중복 확인에 실패했습니다. 다시 시도해 주세요.');
    expect(viewModel.canCheckEmail, isTrue);
  });

  test('changing the input invalidates the previous result', () async {
    viewModel.onNicknameChanged('무비러버');
    await viewModel.checkNickname('무비러버');
    viewModel.onNicknameChanged('무비러버2');
    expect(viewModel.nicknameCheckStatus, CheckStatus.idle);
  });

  test('retyping the duplicated value restores it without a request', () async {
    viewModel.onEmailChanged('movie@umc.com');
    await viewModel.checkEmail('movie@umc.com');
    viewModel.onEmailChanged('movie@umc.co');
    expect(viewModel.emailCheckStatus, CheckStatus.idle);
    expect(viewModel.canCheckEmail, isTrue);

    viewModel.onEmailChanged(' movie@umc.com ');
    expect(viewModel.emailCheckStatus, CheckStatus.duplicated);
    expect(viewModel.emailErrorText, '이미 사용 중인 이메일입니다.');
    expect(viewModel.canCheckEmail, isFalse);
    expect(service.emailCalls, ['movie@umc.com']);
  });

  test('a response for an old input is ignored', () async {
    final gate = service.pending['영화광'] = Completer<void>();
    viewModel.onNicknameChanged('영화광');
    final request = viewModel.checkNickname('영화광');
    expect(viewModel.nicknameCheckStatus, CheckStatus.checking);

    viewModel.onNicknameChanged('무비러버');
    gate.complete();
    await request;
    expect(viewModel.nicknameCheckStatus, CheckStatus.idle);
    expect(viewModel.nicknameErrorText, isNull);
  });

  test('nickname and email results do not affect each other', () async {
    viewModel.onNicknameChanged('영화광');
    await viewModel.checkNickname('영화광');
    expect(viewModel.emailCheckStatus, CheckStatus.idle);
    expect(viewModel.emailErrorText, isNull);
  });

  test(
    'checking is ignored while a request is running or input is empty',
    () async {
      final gate = service.pending['무비러버'] = Completer<void>();
      await viewModel.checkNickname('');
      expect(service.nicknameCalls, isEmpty);

      viewModel.onNicknameChanged('무비러버');
      final request = viewModel.checkNickname('무비러버');
      await viewModel.checkNickname('무비러버');
      expect(service.nicknameCalls, ['무비러버']);
      gate.complete();
      await request;
    },
  );

  test('a response after dispose does not notify', () async {
    final gate = service.pending['무비러버'] = Completer<void>();
    viewModel.onNicknameChanged('무비러버');
    final request = viewModel.checkNickname('무비러버');
    viewModel.dispose();
    gate.complete();
    await expectLater(request, completes);
  });

  group('submit', () {
    const request = CreateMemberRequest(
      email: ' new@umc.com ',
      password: ' Movie!1234 ',
      nickname: ' 무비러버 ',
    );

    test('toJson trims email and nickname but not the password', () {
      expect(request.toJson(), {
        'email': 'new@umc.com',
        'password': ' Movie!1234 ',
        'nickname': '무비러버',
      });
    });

    test('success stores the memberId', () async {
      await viewModel.submit(request);
      expect(viewModel.submitStatus, SubmitStatus.success);
      expect(viewModel.createdMemberId, 77);
    });

    test('a success without memberId is not treated as done', () async {
      service.signUpWithoutId = true;
      await viewModel.submit(request);
      expect(viewModel.submitStatus, SubmitStatus.error);
      expect(viewModel.createdMemberId, isNull);
      expect(viewModel.snackbarMessage, contains('가입 결과'));
    });

    test('a password 400 goes to the field, others to the snackbar', () async {
      service.signUpError = (
        status: 400,
        code: 'COMMON400',
        message: '비밀번호 규칙',
      );
      await viewModel.submit(request);
      expect(viewModel.passwordErrorText, '비밀번호 규칙');
      expect(viewModel.snackbarMessage, isNull);

      service.signUpError = (status: 400, code: 'COMMON400', message: '이메일 형식');
      await viewModel.submit(request);
      expect(viewModel.passwordErrorText, isNull);
      expect(viewModel.snackbarMessage, '이메일 형식');

      service.signUpError = (status: 409, code: 'COMMON409', message: '중복');
      await viewModel.submit(request);
      expect(viewModel.snackbarMessage, '중복');
    });

    test('editing a field clears the previous submit error', () async {
      service.signUpError = (status: 409, code: 'COMMON409', message: '중복');
      await viewModel.submit(request);
      viewModel.onEmailChanged('other@umc.com');
      expect(viewModel.snackbarMessage, isNull);
      expect(viewModel.submitStatus, SubmitStatus.idle);
    });

    test('a second submit while running is ignored', () async {
      final gate = service.signUpGate = Completer<void>();
      final first = viewModel.submit(request);
      await viewModel.submit(request);
      gate.complete();
      await first;
      expect(service.signUpRequests, hasLength(1));
    });
  });
}
