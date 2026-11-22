import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/movielog_button.dart';

/// 8주차 스플래시 화면. 1주차 StartScreen의 로고·제목·설명 레이아웃을 그대로 재사용하고,
/// 하단 '시작하기' 버튼 자리를 세션 확인 상태로 대체한다.
/// - [onRetry]가 null: 토큰 확인 중(initializing) → 인디케이터
/// - [onRetry]가 있음: 확인 실패(retryRequired) → 안내 문구 + 다시 시도 버튼
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                children: [
                  const Text(
                    'FLUTTER 8주차',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xff494551),
                      height: 16 / 11,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 60),
                    child: SvgPicture.asset(
                      'assets/logos/movielog_Icon.svg',
                      width: 60,
                      height: 48,
                      semanticsLabel: 'MovieLog 로고',
                    ),
                  ),
                  const Text(
                    '영화의 순간을\n기록하세요',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
              child: onRetry == null
                  ? const SizedBox(
                      height: 56,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message ?? '로그인 상태를 확인하지 못했어요.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        MovieLogButton(
                          label: '다시 시도',
                          width: double.infinity,
                          height: 56,
                          onPressed: onRetry,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
