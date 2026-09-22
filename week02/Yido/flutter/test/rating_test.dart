import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movielog/rating_screen.dart';
import 'package:movielog/theme/app_theme.dart';

void main() {
  testWidgets('rating enables save and confirms the selected local value', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const RatingScreen()),
    );

    final saveButton = find.byKey(const Key('saveRatingButton'));
    expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNull);

    final starTapTargets = find.descendant(
      of: find.byType(RatingBar),
      matching: find.byType(GestureDetector),
    );
    final bounds = tester.getRect(starTapTargets.at(3));
    final gesture = await tester.startGesture(
      Offset(bounds.center.dx + 8, bounds.center.dy),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNotNull);
    final selectedText = tester.widget<Text>(find.textContaining('선택한 별점:'));
    final selectedRating = RegExp(r'([0-5]\.\d)점')
        .firstMatch(selectedText.data!)!
        .group(1)!;

    await tester.tap(saveButton);
    await tester.pump();
    expect(find.text('로컬 연습으로 $selectedRating점을 저장했습니다.'), findsOneWidget);
    expect(find.text('$selectedRating점이 로컬로 저장되었습니다.'), findsOneWidget);
  });
}
