import 'package:deku/screens/rating/rating_screen.dart';
import 'package:deku/screens/sign_up/sign_up_screen.dart';
import 'package:deku/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('회원가입 화면은 필수 입력 요소를 표시한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_testApp(const SignUpScreen()));

    expect(find.text('회원가입'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('필수 약관에 동의합니다'), findsOneWidget);
    expect(find.text('가입하기'), findsOneWidget);

    final submitButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('sign-up-submit-button')),
    );
    expect(submitButton.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('각 입력창에 한국어 Validation 오류를 표시한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_testApp(const SignUpScreen()));

    await tester.enterText(_textFieldInside('nickname-field'), 'a');
    await tester.enterText(_textFieldInside('email-field'), 'test@');
    await tester.enterText(_textFieldInside('password-field'), '123');
    await tester.pump();

    expect(find.text('닉네임은 2자 이상이어야 합니다.'), findsOneWidget);
    expect(find.text('올바른 이메일 형식이 아닙니다.'), findsOneWidget);
    expect(find.text('비밀번호는 8자 이상이어야 합니다.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('모든 조건이 유효할 때만 가입 버튼을 활성화한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_testApp(const SignUpScreen()));

    await tester.enterText(_textFieldInside('nickname-field'), '무비러버');
    await tester.enterText(
      _textFieldInside('email-field'),
      'movie@example.com',
    );
    await tester.enterText(_textFieldInside('password-field'), 'password123');
    await tester.pump();

    ElevatedButton submitButton = tester.widget(
      find.byKey(const Key('sign-up-submit-button')),
    );
    expect(submitButton.onPressed, isNull);

    await tester.ensureVisible(find.byKey(const Key('terms-checkbox')));
    await tester.tap(find.byKey(const Key('terms-checkbox')));
    await tester.pump();

    submitButton = tester.widget(
      find.byKey(const Key('sign-up-submit-button')),
    );
    expect(submitButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('sign-up-submit-button')));
    await tester.pump();
    expect(find.text('입력값 검증이 완료되었습니다.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('키보드가 화면을 가리는 크기에서도 Form을 스크롤할 수 있다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(viewInsets: const EdgeInsets.only(bottom: 320)),
          child: child!,
        ),
        home: const SignUpScreen(),
      ),
    );

    expect(find.byKey(const Key('sign-up-scroll-view')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('sign-up-submit-button')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('별점을 선택하면 평점 저장 버튼을 활성화한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_testApp(const RatingScreen()));

    expect(find.byType(RatingBar), findsOneWidget);
    expect(find.text('평점을 선택해주세요.'), findsOneWidget);

    ElevatedButton saveButton = tester.widget(
      find.byKey(const Key('save-rating-button')),
    );
    expect(saveButton.onPressed, isNull);

    final ratingBar = find.byKey(const Key('movie-rating-bar'));
    final topLeft = tester.getTopLeft(ratingBar);
    await tester.tapAt(topLeft + const Offset(120, 24));
    await tester.pump();

    saveButton = tester.widget(find.byKey(const Key('save-rating-button')));
    expect(saveButton.onPressed, isNotNull);
    expect(find.textContaining('선택한 평점:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

Finder _textFieldInside(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(TextFormField),
);

void _setSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
