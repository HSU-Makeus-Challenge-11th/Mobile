import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/rating_screen.dart';
import 'package:movielog/sign_up_screen.dart';
import 'package:movielog/theme/app_theme.dart';

void main() {
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
        home: const SignUpScreen(),
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
  }

  ElevatedButton signUpButton(WidgetTester tester) =>
      tester.widget(find.byKey(const Key('signUpButton')));

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
    expect(normalContainer!.size.height, 42);
    expect(
      tester
          .getSize(
            find.ancestor(of: nickname, matching: find.byType(Column)).first,
          )
          .height,
      70,
    );
    expect(tester.getSize(find.byKey(const Key('signUpButton'))).height, 56);

    await tester.enterText(nickname, '가');
    await tester.pumpAndSettle();
    final errorContainer = InputDecorator.containerOf(
      tester.element(
        find.descendant(of: nickname, matching: find.byType(EditableText)),
      ),
    );
    expect(errorContainer, isNotNull);
    expect(errorContainer!.size.height, 42);
    expect(
      tester
          .getSize(
            find.ancestor(of: nickname, matching: find.byType(Column)).first,
          )
          .height,
      94,
    );
  });

  testWidgets('valid signup opens the rating screen', (tester) async {
    await pumpScreen(tester);
    await enterValidDetails(tester);
    await tester.ensureVisible(find.byKey(const Key('termsCheckbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('termsCheckbox')));
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('signUpButton')));
    await tester.tap(find.byKey(const Key('signUpButton')));
    await tester.pumpAndSettle();
    expect(find.byType(RatingScreen), findsOneWidget);
  });
}
