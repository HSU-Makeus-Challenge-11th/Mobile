import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/genre_preference.dart';
import 'package:movielog/movie_list_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Widget app() => const MaterialApp(home: Scaffold(body: MovieListScreen()));

  Future<void> pickMode(WidgetTester tester, String label) async {
    await tester.longPress(find.text('영화'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pump();
  }

  testWidgets('Loading 후 Success, Empty, Error와 재시도', (tester) async {
    await tester.pumpWidget(app());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('별빛 아래 우리'), findsOneWidget);

    await pickMode(tester, '빈 목록');
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('조건에 맞는 영화가 없습니다.'), findsOneWidget);

    await pickMode(tester, '실패');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('다시 시도'), findsOneWidget);
    expect(find.textContaining('MovieLoadException'), findsNothing);

    await tester.tap(find.byKey(const Key('retryButton')));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('별빛 아래 우리'), findsOneWidget);
  });

  testWidgets('선택한 장르를 저장하고 다시 열면 복원', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('SF'));
    await tester.pump();
    expect(await GenrePreference().read(), 'SF');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('우주의 끝에서'), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsNothing);
  });
}
