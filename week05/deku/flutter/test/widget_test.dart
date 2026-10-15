import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:deku/constants/app_assets.dart';
import 'package:deku/main.dart';
import 'package:deku/screens/profile/profile_screen.dart';
import 'package:deku/screens/profile/widgets/stat_item.dart';
import 'package:deku/screens/start/start_screen.dart';
import 'package:deku/theme/app_colors.dart';
import 'package:deku/theme/app_dimensions.dart';
import 'package:deku/theme/app_text_styles.dart';
import 'package:deku/theme/app_theme.dart';

void main() {
  testWidgets('프로필 화면에 과제 필수 콘텐츠를 표시한다', (tester) async {
    _setSurface(tester, const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('내 프로필'), findsOneWidget);
    expect(find.text('무비러버'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(StatItem), findsNWidgets(3));
    expect(find.text('342'), findsOneWidget);
    expect(find.text('4.2'), findsOneWidget);
    expect(find.text('58'), findsOneWidget);
    expect(find.text('드라마'), findsOneWidget);
    expect(find.text('SF'), findsOneWidget);
    expect(find.text('애니메이션'), findsOneWidget);
    expect(find.text('프로필 수정'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('프로필 화면에 Final Sync 규격을 적용한다', (tester) async {
    _setSurface(tester, const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const Key('profile-photo'))),
      const Size.square(128),
    );
    expect(
      tester.getSize(find.byKey(const Key('edit-profile-button'))),
      const Size(128, 42),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('stat-item-본 영화'))),
      const Size(114, 86),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('genre-chip-드라마'))).height,
      32,
    );

    final appBarTitle = tester.widget<Text>(find.text('내 프로필'));
    final profileName = tester.widget<Text>(find.text('무비러버'));
    final description = tester.widget<Text>(
      find.text('매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.'),
    );
    final genreTitle = tester.widget<Text>(find.text('선호하는 장르'));

    expect(appBarTitle.style, AppTextStyles.profileAppBarTitle);
    expect(profileName.style, AppTextStyles.profileName);
    expect(description.style, AppTextStyles.profileDescription);
    expect(genreTitle.style, AppTextStyles.profileSectionTitle);

    final statCard = tester.widget<Container>(
      find.byKey(const ValueKey('stat-item-본 영화')),
    );
    final statDecoration = statCard.decoration! as BoxDecoration;
    expect(statDecoration.color, AppColors.surfaceLow);
    expect(statDecoration.borderRadius, AppRadius.large);
    expect((statDecoration.border! as Border).top.color, AppColors.primary200);
    expect(tester.takeException(), isNull);
  });

  testWidgets('시작 화면은 MovieLog SVG 로고를 표시한다', (tester) async {
    _setSurface(tester, const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const StartScreen()),
    );

    expect(find.text('FLUTTER 1주차'), findsOneWidget);
    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byIcon(Icons.movie_outlined), findsNothing);
    expect(find.text('시작하기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('시작 화면은 짧은 가로 화면에서 스크롤된다', (tester) async {
    _setSurface(tester, const Size(844, 390));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const StartScreen()),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('프로필 화면은 큰 글자에서도 콘텐츠를 자르지 않는다', (tester) async {
    _setSurface(tester, const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StatItem), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('과제용 이미지와 SVG가 AssetBundle에 등록되어 있다', (tester) async {
    await tester.pumpWidget(const MyApp());

    final profileBytes = await rootBundle.load(AppAssets.profile);
    final logoBytes = await rootBundle.load(AppAssets.movieLogLogo);
    final movieIconBytes = await rootBundle.load(AppAssets.movieIcon);
    final personIconBytes = await rootBundle.load(AppAssets.personIcon);

    expect(profileBytes.lengthInBytes, greaterThan(0));
    expect(logoBytes.lengthInBytes, greaterThan(0));
    expect(movieIconBytes.lengthInBytes, greaterThan(0));
    expect(personIconBytes.lengthInBytes, greaterThan(0));
  });

  test('MovieLog 기본 테마 토큰을 연결한다', () {
    final theme = AppTheme.light;

    expect(theme.colorScheme.primary, AppColors.primary500);
    expect(theme.colorScheme.surface, AppColors.surfaceBase);
    expect(theme.scaffoldBackgroundColor, AppColors.surfaceBase);
    expect(theme.textTheme.titleLarge?.fontFamily, 'Manrope');
  });
}

void _setSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
