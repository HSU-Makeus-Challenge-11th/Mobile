import 'package:deku/constants/app_assets.dart';
import 'package:deku/core/storage/token_storage.dart';
import 'package:deku/data/models/member_info.dart';
import 'package:deku/data/services/auth_api_service.dart';
import 'package:deku/data/services/member_api_service.dart';
import 'package:deku/screens/login/login_screen.dart';
import 'package:deku/screens/profile/profile_screen.dart';
import 'package:deku/screens/start/start_screen.dart';
import 'package:deku/theme/app_colors.dart';
import 'package:deku/theme/app_theme.dart';
import 'package:deku/view_models/auth_view_model.dart';
import 'package:deku/view_models/session_ratings_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('초기화 중에는 로그인 폼 대신 세션 확인 화면을 표시한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    final auth = _auth();
    await tester.pumpWidget(_app(auth, const StartScreen()));
    expect(find.text('로그인 상태를 확인하고 있어요.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('로그인 화면은 이메일 형식을 검증한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    final auth = _auth()..status = AuthStatus.signedOut;
    await tester.pumpWidget(_app(auth, const LoginScreen()));
    await tester.enterText(
      find.byKey(const Key('login-email-field')),
      'bad-email',
    );
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      'password',
    );
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pump();
    expect(find.text('올바른 이메일을 입력해 주세요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('마이페이지는 기존 섹션과 GET me 값을 함께 표시한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    final auth = _auth()
      ..status = AuthStatus.signedIn
      ..memberStatus = MemberLoadStatus.success
      ..member = MemberInfo(
        email: 'movie@example.com',
        nickname: '시네필',
        createdAt: DateTime(2026, 11, 16),
      );
    await tester.pumpWidget(_app(auth, const ProfileScreen()));
    expect(find.text('시네필'), findsOneWidget);
    expect(find.text('2026.11.16 가입'), findsOneWidget);
    expect(find.text('movie@example.com'), findsOneWidget);
    expect(find.byKey(const Key('logout-button')), findsOneWidget);
    expect(find.byKey(const Key('profile-photo')), findsOneWidget);
    expect(find.text('342'), findsOneWidget);
    expect(find.text('4.2'), findsOneWidget);
    expect(find.text('58'), findsOneWidget);
    expect(find.text('선호하는 장르'), findsOneWidget);
    expect(find.text('드라마'), findsOneWidget);
    expect(find.text('내가 등록한 평점'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('마이페이지는 내 정보 실패 시 재시도를 제공한다', (tester) async {
    final auth = _auth()
      ..status = AuthStatus.signedIn
      ..memberStatus = MemberLoadStatus.error;
    await tester.pumpWidget(_app(auth, const ProfileScreen()));
    expect(find.byKey(const Key('member-retry-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('과제 이미지와 SVG가 AssetBundle에 등록되어 있다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    for (final asset in [
      AppAssets.profile,
      AppAssets.movieLogLogo,
      AppAssets.movieIcon,
      AppAssets.personIcon,
    ]) {
      expect((await rootBundle.load(asset)).lengthInBytes, greaterThan(0));
    }
  });

  test('MovieLog 기본 테마 토큰을 연결한다', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.primary, AppColors.primary500);
    expect(theme.colorScheme.surface, AppColors.surfaceBase);
    expect(theme.scaffoldBackgroundColor, AppColors.surfaceBase);
    expect(theme.textTheme.titleLarge?.fontFamily, 'Manrope');
  });
}

Widget _app(AuthViewModel auth, Widget home) => ChangeNotifierProvider.value(
  value: auth,
  child: MaterialApp(theme: AppTheme.light, home: home),
);

AuthViewModel _auth() => AuthViewModel(
  AuthApiService(Dio()),
  MemberApiService(Dio()),
  _MemoryTokenStorage(),
  SessionRatingsStore(),
);

class _MemoryTokenStorage implements TokenStorage {
  @override
  Future<void> deleteAccessToken() async {}
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<void> saveAccessToken(String token) async {}
}

void _setSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
