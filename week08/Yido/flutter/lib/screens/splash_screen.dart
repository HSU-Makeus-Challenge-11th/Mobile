import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:movielog/widgets/movielog_button.dart';

/// 1주차 시작 화면 레이아웃을 재사용한 세션 확인 화면 (W8-01, W8-02).
/// onRetry가 없으면 확인 중, 있으면 확인 실패 상태다
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  static const _muted = AppColors.mutedText;

  Widget _line(
    double top,
    String text,
    double size,
    FontWeight weight,
    Color color,
  ) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Text(
        text,
        textAlign: TextAlign.center,
        strutStyle: w8Strut(size),
        style: w8Text(size, weight, color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Scaffold(
      backgroundColor: AppColors.surfaceBright,
      body: SafeArea(
        child: Stack(
          children: [
            _line(65.64, 'FLUTTER 8주차', 12, FontWeight.w500, _muted),
            Positioned(
              top: 159,
              left: 0,
              right: 0,
              child: Center(
                child: SvgPicture.asset(
                  'assets/logos/movielog_logo.svg',
                  width: 60,
                  height: 48,
                  semanticsLabel: 'MovieLog 로고',
                ),
              ),
            ),
            _line(261.22, '영화의 순간을', 26, FontWeight.w700, AppColors.ink),
            _line(295.22, '기록하세요', 26, FontWeight.w700, AppColors.ink),
            _line(349.58, '보고 싶은 영화부터 나만의 평점까지', 14, FontWeight.w500, _muted),
            _line(373.58, '한곳에서 관리해요', 14, FontWeight.w500, _muted),
            // 하단 요소는 프레임 아래쪽에서 잰 거리로 둔다
            if (retry == null)
              const Positioned(
                bottom: 55,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      key: Key('splashProgress'),
                      strokeWidth: 2,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              )
            else ...[
              Positioned(
                bottom: 122.42,
                left: 32,
                right: 32,
                child: Text(
                  message ?? '로그인 상태를 확인하지 못했어요.',
                  textAlign: TextAlign.center,
                  strutStyle: w8Strut(14),
                  style: w8Text(14, FontWeight.w500, _muted),
                ),
              ),
              Positioned(
                bottom: 52,
                left: 32,
                right: 32,
                child: MovieLogButton(
                  key: const Key('splashRetryButton'),
                  label: '다시 시도',
                  width: double.infinity,
                  labelStyle: w8Text(14, FontWeight.w700, AppColors.white),
                  onPressed: retry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
