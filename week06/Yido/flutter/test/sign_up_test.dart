import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:provider/provider.dart';

import 'support/fake_member_services.dart';

void main() {
  late FakeMemberCheckService service;

  setUp(() => service = FakeMemberCheckService(duplicated: {'영화광'}));

  Future<void> pumpScreen(
    WidgetTester tester, {
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(viewInsets: viewInsets),
          child: child!,
        ),
        home: ChangeNotifierProvider(
          create: (_) => SignUpViewModel(service),
          child: const SignUpScreen(),
        ),
      ),
    );
  }

  Future<void> enterValidDetails(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('nicknameField')), 'Yido');
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'movie@example.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'movie1234');
    await tester.pump();
    await tester.tap(find.byKey(const Key('nicknameCheckButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('emailCheckButton')));
    await tester.pump();
  }

  ElevatedButton buttonOf(WidgetTester tester, String key) => tester.widget(
    find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byType(ElevatedButton),
    ),
  );

  ElevatedButton signUpButton(WidgetTester tester) =>
      buttonOf(tester, 'signUpButton');

  testWidgets('signup starts disabled without validation errors', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(signUpButton(tester).onPressed, isNull);
    expect(find.text('닉네임을 입력해 주세요.'), findsNothing);
    expect(find.text('이메일을 입력해 주세요.'), findsNothing);
    expect(find.text('비밀번호를 입력해 주세요.'), findsNothing);
  });

  testWidgets('invalid inputs show Korean errors and stay disabled', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.enterText(find.byKey(const Key('nicknameField')), '가');
    await tester.enterText(find.byKey(const Key('emailField')), 'invalid');
    await tester.enterText(find.byKey(const Key('passwordField')), '1234');
    await tester.pump();

    expect(find.text('닉네임은 2자 이상이어야 합니다.'), findsOneWidget);
    expect(find.text('올바른 이메일 형식을 입력해 주세요.'), findsOneWidget);
    expect(find.text('비밀번호는 8자 이상이어야 합니다.'), findsOneWidget);
    expect(signUpButton(tester).onPressed, isNull);
  });

  testWidgets('valid values and consent enable signup, then revoke it', (
    tester,
  ) async {
    await pumpScreen(tester);
    await enterValidDetails(tester);

    await tester.ensureVisible(find.byKey(const Key('termsCheckbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('termsCheckbox')));
    await tester.pump();
    expect(signUpButton(tester).onPressed, isNotNull);

    await tester.enterText(find.byKey(const Key('emailField')), '');
    await tester.pump();
    expect(signUpButton(tester).onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'movie@example.com',
    );
    await tester.pump();
    // 입력을 바꾸면 이전 확인 결과가 사라져 다시 확인해야 한다
    expect(signUpButton(tester).onPressed, isNull);
    await tester.tap(find.byKey(const Key('emailCheckButton')));
    await tester.pump();
    expect(signUpButton(tester).onPressed, isNotNull);

    await tester.ensureVisible(find.byKey(const Key('termsCheckbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('termsCheckbox')));
    await tester.pump();
    expect(signUpButton(tester).onPressed, isNull);
  });

  testWidgets('IME next advances focus and done leaves all fields', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const Key('nicknameField')));
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('emailField')),
              matching: find.byType(TextField),
            ),
          )
          .focusNode!
          .hasFocus,
      isTrue,
    );

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('passwordField')),
              matching: find.byType(TextField),
            ),
          )
          .focusNode!
          .hasFocus,
      isTrue,
    );

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    for (final key in const [
      Key('nicknameField'),
      Key('emailField'),
      Key('passwordField'),
    ]) {
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byKey(key),
                matching: find.byType(TextField),
              ),
            )
            .focusNode!
            .hasFocus,
        isFalse,
      );
    }
  });

  testWidgets(
    'small keyboard viewport scrolls actions into view without overflow',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpScreen(tester, viewInsets: const EdgeInsets.only(bottom: 260));

      final signUp = find.byKey(const Key('signUpButton'));
      final outerScrollable = find
          .descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(signUp, 200, scrollable: outerScrollable);
      expect(signUp, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('signup controls follow the CSS geometry', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpScreen(tester);

    final nickname = find.byKey(const Key('nicknameField'));
    final normalContainer = InputDecorator.containerOf(
      tester.element(
        find.descendant(of: nickname, matching: find.byType(EditableText)),
      ),
    );
    expect(normalContainer, isNotNull);
    expect(normalContainer!.size.height, 44);
    expect(
      tester
          .getSize(
            find.ancestor(of: nickname, matching: find.byType(Column)).first,
          )
          .height,
      72,
    );
    expect(tester.getSize(find.byKey(const Key('signUpButton'))).height, 44);

    await tester.enterText(nickname, '가');
    await tester.pumpAndSettle();
    final errorContainer = InputDecorator.containerOf(
      tester.element(
        find.descendant(of: nickname, matching: find.byType(EditableText)),
      ),
    );
    expect(errorContainer, isNotNull);
    expect(errorContainer!.size.height, 44);
    expect(find.text('닉네임은 2자 이상이어야 합니다.'), findsOneWidget);
  });

  group('duplicate check on the form', () {
    Future<void> enterNickname(WidgetTester tester, String value) async {
      await tester.enterText(find.byKey(const Key('nicknameField')), value);
      await tester.pump();
    }

    testWidgets('check button stays disabled until the format is valid', (
      tester,
    ) async {
      await pumpScreen(tester);
      expect(buttonOf(tester, 'nicknameCheckButton').onPressed, isNull);
      await enterNickname(tester, '가');
      expect(buttonOf(tester, 'nicknameCheckButton').onPressed, isNull);
      await enterNickname(tester, '가나');
      expect(buttonOf(tester, 'nicknameCheckButton').onPressed, isNotNull);
    });

    testWidgets('checking shows a spinner and keeps the button width', (
      tester,
    ) async {
      final gate = service.pending['무비러버'] = Completer<void>();
      await pumpScreen(tester);
      await enterNickname(tester, '무비러버');
      final idleWidth = tester
          .getSize(find.byKey(const Key('nicknameCheckButton')))
          .width;

      await tester.tap(find.byKey(const Key('nicknameCheckButton')));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('닉네임 사용 가능 여부를 확인 중입니다.'), findsOneWidget);
      expect(buttonOf(tester, 'nicknameCheckButton').onPressed, isNull);
      expect(
        tester.getSize(find.byKey(const Key('nicknameCheckButton'))).width,
        idleWidth,
      );

      gate.complete();
      await tester.pump();
      expect(find.text('사용 가능한 닉네임입니다.'), findsOneWidget);
    });

    testWidgets('duplicate shows the error and retyping restores it', (
      tester,
    ) async {
      await pumpScreen(tester);
      await enterNickname(tester, '영화광');
      await tester.tap(find.byKey(const Key('nicknameCheckButton')));
      await tester.pump();
      expect(find.text('이미 사용 중인 닉네임입니다.'), findsOneWidget);
      expect(buttonOf(tester, 'nicknameCheckButton').onPressed, isNull);

      await enterNickname(tester, '영화광2');
      expect(find.text('이미 사용 중인 닉네임입니다.'), findsNothing);
      expect(buttonOf(tester, 'nicknameCheckButton').onPressed, isNotNull);

      await enterNickname(tester, '영화광');
      expect(find.text('이미 사용 중인 닉네임입니다.'), findsOneWidget);
      expect(buttonOf(tester, 'nicknameCheckButton').onPressed, isNull);
      expect(service.nicknameCalls, ['영화광']);
    });

    testWidgets('network failure has its own message', (tester) async {
      service.fail = true;
      await pumpScreen(tester);
      await enterNickname(tester, '무비러버');
      await tester.tap(find.byKey(const Key('nicknameCheckButton')));
      await tester.pump();
      expect(find.text('중복 확인에 실패했습니다. 다시 시도해 주세요.'), findsOneWidget);
      expect(find.text('이미 사용 중인 닉네임입니다.'), findsNothing);
      expect(buttonOf(tester, 'nicknameCheckButton').onPressed, isNotNull);
    });
  });
}
