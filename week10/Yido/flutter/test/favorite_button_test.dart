import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/view_models/favorite_detail_view_model.dart';
import 'package:movielog/widgets/favorites/bookmark_icon.dart';
import 'package:movielog/widgets/favorites/favorite_button.dart';
import 'package:provider/provider.dart';

import 'support/fake_favorite_api.dart';

void main() {
  late FakeFavoriteApi api;
  late FavoriteDetailViewModel vm;

  Future<void> pump(WidgetTester tester) async {
    final guard = SessionGuard()..startSession('a@umc.com');
    vm = FavoriteDetailViewModel(
      movieId: 550,
      favoriteApi: api,
      sessionGuard: guard,
      accountId: 'a@umc.com',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider.value(
            value: vm,
            child: const Center(child: FavoriteButton()),
          ),
        ),
      ),
    );
    await vm.load();
    await tester.pump();
  }

  BookmarkIcon icon(WidgetTester tester) =>
      tester.widget<BookmarkIcon>(find.byType(BookmarkIcon));

  testWidgets('saving shows only the spinner in the bookmark slot', (
    tester,
  ) async {
    api = FakeFavoriteApi();
    await pump(tester);
    expect(icon(tester).filled, isFalse);
    api.gate = Completer<void>();
    await tester.tap(find.byKey(const Key('favoriteButton')));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(BookmarkIcon), findsNothing);
    expect(find.text('즐겨찾기'), findsOneWidget);
    api.gate!.complete();
    await tester.pumpAndSettle();
    expect(icon(tester).filled, isTrue);
    expect(find.text('즐겨찾기에 추가했습니다.'), findsOneWidget);
  });

  testWidgets('a failure keeps the outline and shows the message', (
    tester,
  ) async {
    api = FakeFavoriteApi();
    await pump(tester);
    api.writeError = DioException(requestOptions: RequestOptions());
    await tester.tap(find.byKey(const Key('favoriteButton')));
    await tester.pumpAndSettle();
    expect(icon(tester).filled, isFalse);
    expect(find.text('저장하지 못했습니다. 다시 시도해 주세요.'), findsOneWidget);
  });

  testWidgets('a failed first check offers a retry instead of a tap', (
    tester,
  ) async {
    api = FakeFavoriteApi()
      ..checkError = DioException(requestOptions: RequestOptions());
    await pump(tester);
    await tester.tap(find.byKey(const Key('favoriteButton')));
    await tester.pump();
    expect(api.addCalls, 0);
    api.checkError = null;
    await tester.tap(find.byKey(const Key('favoriteRetryButton')));
    await tester.pumpAndSettle();
    expect(vm.hasLoadedStatus, isTrue);
    expect(find.byKey(const Key('favoriteRetryButton')), findsNothing);
  });
}
