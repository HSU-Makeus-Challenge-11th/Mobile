import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// MovieLog 시작 화면 (W1-00).
/// 버튼은 로그만 출력하고 화면 이동은 하지 않는다.
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
              const Text('FLUTTER 1주차', style: AppTextStyles.labelSmall),
              const SizedBox(height: 24),
              SizedBox(
                width: 128,
                height: 128,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/logos/movielog_logo.svg',
                    width: 60,
                    height: 48,
                    semanticsLabel: 'MovieLog 로고',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // 한글은 글자 단위로 줄바꿈되므로 의미 단위로 직접 끊는다.
              const Text(
                '영화의 순간을\n기록하세요',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium,
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
                    backgroundColor: AppColors.primary600,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: AppTextStyles.labelLarge,
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
