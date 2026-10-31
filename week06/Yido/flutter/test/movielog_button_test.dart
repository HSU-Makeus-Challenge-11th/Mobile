import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/widgets/movielog_button.dart';

void main() {
  Future<void> pumpInRow(WidgetTester tester, MovieLogButton button) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Column(children: [button])),
      ),
    );
  }

  ElevatedButton button(WidgetTester tester) =>
      tester.widget(find.byType(ElevatedButton));

  testWidgets('default state runs the callback', (tester) async {
    var pressed = 0;
    await pumpInRow(
      tester,
      MovieLogButton(label: '확인', onPressed: () => pressed++),
    );
    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('loading disables and draws only the indicator', (tester) async {
    await pumpInRow(
      tester,
      MovieLogButton(label: '확인', isLoading: true, onPressed: () {}),
    );
    expect(button(tester).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // 글자는 너비를 잡는 자리로만 남고 화면에 그려지지 않는다
    expect(tester.widget<Visibility>(find.byType(Visibility)).visible, isFalse);
  });

  testWidgets('a null callback disables the button', (tester) async {
    await pumpInRow(tester, const MovieLogButton(label: '확인', onPressed: null));
    expect(button(tester).onPressed, isNull);
  });

  testWidgets('width follows null, infinity and a fixed value', (tester) async {
    double widthFor(double? width) =>
        tester.getSize(find.byType(SizedBox).first).width;

    await pumpInRow(tester, MovieLogButton(label: '중복 확인', onPressed: () {}));
    expect(widthFor(null), lessThan(200));

    await pumpInRow(
      tester,
      MovieLogButton(label: '중복 확인', width: 120, onPressed: () {}),
    );
    expect(widthFor(120), 120);

    await pumpInRow(
      tester,
      MovieLogButton(label: '중복 확인', width: double.infinity, onPressed: () {}),
    );
    expect(widthFor(double.infinity), 390);
  });
}
