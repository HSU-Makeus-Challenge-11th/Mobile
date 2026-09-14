import 'package:flutter/material.dart';

/// MovieLog 시작 화면 (W0-01).
/// 0주차에는 버튼이 로그만 출력하고 화면 이동은 하지 않는다.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 위아래 Spacer로 아이콘과 문구를 화면 가운데에 둔다.
              const Spacer(),
              Icon(
                Icons.movie_outlined,
                size: 72,
                color: colorScheme.primary,
                semanticLabel: 'MovieLog 로고',
              ),
              const SizedBox(height: 24),
              const Text(
                '영화의 순간을 기록하세요',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                // 한글은 글자 단위로 줄바꿈되므로 의미 단위로 직접 끊는다.
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  debugPrint('시작하기 버튼을 눌렀습니다.');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
