import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/movielog_button.dart';

/// 앱 시작 스플래시입니다. 1주차 시작 화면 레이아웃을 그대로 쓰고,
/// 하단 '시작하기' 버튼 자리에 세션 확인 중(로딩) / 확인 실패(다시 시도)를 보여줍니다.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry; // null이면 확인 중, 있으면 재시도 상태입니다.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'FLUTTER 8주차',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  color: AppColors.grayDark,
                ),
              ),
              SizedBox(height: 64),
              SvgPicture.asset(
                'assets/logos/movielog_logo.svg',
                width: 72,
                height: 72,
                semanticsLabel: 'MovieLog 로고',
              ),
              SizedBox(height: 24),
              Text(
                '영화의 순간을\n기록하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.grayDark,
                ),
              ),
              Spacer(),
              if (onRetry == null)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(color: AppColors.violet),
                )
              else ...[
                Text(
                  message ?? '로그인 상태를 확인하지 못했어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.grayDark),
                ),
                const SizedBox(height: 16),
                MovieLogButton(
                  label: '다시 시도',
                  width: double.infinity,
                  height: 56,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
