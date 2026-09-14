import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movielog/movie_log_app.dart';

void main() {
  testWidgets('시작 화면에 아이콘, 문구, 시작하기 버튼이 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieLogApp());

    expect(find.text('FLUTTER 0주차'), findsOneWidget);
    expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
    expect(find.text('보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '시작하기'), findsOneWidget);

    // 0주차 버튼은 로그만 출력하므로 눌러도 화면이 그대로여야 한다.
    await tester.tap(find.text('시작하기'));
    await tester.pump();
    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
  });
}
