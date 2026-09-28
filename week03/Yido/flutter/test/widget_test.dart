import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movielog/profile_screen.dart';
import 'package:movielog/start_screen.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/widgets/profile/stat_item.dart';

void main() {
  testWidgets('시작 화면에 로고, 문구, 시작하기 버튼이 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const StartScreen()),
    );

    expect(find.text('FLUTTER 1주차'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byIcon(Icons.movie_outlined), findsNothing);
    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
    expect(find.text('보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '시작하기'), findsOneWidget);

    // 버튼은 로그만 출력하므로 눌러도 화면이 그대로여야 한다.
    await tester.tap(find.text('시작하기'));
    await tester.pump();
    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
  });

  testWidgets('내 프로필 화면에 헤더, 통계, 장르가 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
    );

    expect(find.text('내 프로필'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('무비러버'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '프로필 수정'), findsOneWidget);

    expect(find.byType(StatItem), findsNWidgets(3));
    for (final value in ['342', '4.2', '58']) {
      expect(find.text(value), findsOneWidget);
    }

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(Chip), findsNWidgets(3));
    for (final genre in ['드라마', 'SF', '애니메이션']) {
      expect(find.widgetWithText(Chip, genre), findsOneWidget);
    }
  });
}
