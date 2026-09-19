import 'package:flutter/material.dart';

// W0-01 디자인 색상
const _iconColor = Color(0xFF6750A4);
const _titleColor = Color(0xFF1B1C1A);
const _subTextColor = Color(0xFF494551);
const _buttonColor = Color(0xFF4F378A);

/// MovieLog 시작 화면 (W0-01).
/// 0주차에는 버튼이 로그만 출력하고 화면 이동은 하지 않는다.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Text(
                'FLUTTER 0주차',
                style: TextStyle(
                  fontSize: 11,
                  height: 16 / 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.55,
                  color: _subTextColor,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 128,
                height: 128,
                child: Icon(
                  Icons.movie_outlined,
                  size: 72,
                  color: _iconColor,
                  semanticLabel: 'MovieLog 로고',
                ),
              ),
              const SizedBox(height: 32),
              // 한글은 글자 단위로 줄바꿈되므로 의미 단위로 직접 끊는다.
              const Text(
                '영화의 순간을\n기록하세요',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 28,
                  height: 36 / 28,
                  fontWeight: FontWeight.w500,
                  color: _titleColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.25,
                  color: _subTextColor,
                ),
              ),
              // 문구는 위쪽에, 버튼은 맨 아래에 둔다.
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('시작하기 버튼을 눌렀습니다.');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                  child: const Text('시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
