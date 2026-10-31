import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';

import 'support/fake_member_services.dart';

void main() {
  late FakeMemberCheckService service;
  late SignUpViewModel viewModel;

  setUp(() {
    service = FakeMemberCheckService(duplicated: {'영화광', 'movie@umc.com'});
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
}
