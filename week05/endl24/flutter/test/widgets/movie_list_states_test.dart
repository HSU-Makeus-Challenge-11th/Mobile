import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/widgets/movie_list_empty.dart';
import 'package:movielog/widgets/movie_list_error.dart';
import 'package:movielog/widgets/movie_list_loading.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('Loading은 Skeleton Grid를 보여준다', (tester) async {
    await tester.pumpWidget(_wrap(const MovieListLoading()));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Empty는 안내 문구를 보여준다', (tester) async {
    await tester.pumpWidget(_wrap(const MovieListEmpty()));

    expect(find.text('조건에 맞는 영화가 없습니다.'), findsOneWidget);
  });

  testWidgets('Error는 안내 문구와 다시 시도 버튼을 보여준다', (tester) async {
    await tester.pumpWidget(_wrap(MovieListError(onRetry: () {})));

    expect(find.text('영화를 불러오지 못했습니다.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('Error의 다시 시도 버튼을 누르면 onRetry가 호출된다', (tester) async {
    var retried = false;

    await tester.pumpWidget(_wrap(MovieListError(onRetry: () => retried = true)));
    await tester.tap(find.text('다시 시도'));

    expect(retried, isTrue);
  });
}