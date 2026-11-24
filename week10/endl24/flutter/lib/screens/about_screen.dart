import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/about_view_model.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:provider/provider.dart';

/// 마이페이지 → 앱 정보 화면입니다(하단 탭 없음).
/// 앱 버전과 TMDB 출처 표기를 보여 줍니다.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const routePath = '/my/about';

  @override
  Widget build(BuildContext context) {
    final versionLabel = context.watch<AboutViewModel>().versionLabel;

    return Scaffold(
      appBar: CommonAppBar(
        title: '앱 정보',
        centerTitle: true,
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          Center(
            child: Image.asset('assets/logos/movielog_logo.png', width: 84),
          ),
          const SizedBox(height: 32),
          const Text(
            'MovieLog',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            '버전 $versionLabel',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 36),
          const _TmdbAttributionCard(),
          const SizedBox(height: 28),
          const Text('오픈소스 라이선스', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          const Text(
            'Manrope · Material Symbols',
            style: AppTextStyles.bodyMedium,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'MovieLog',
              ),
              child: const Text('Flutter/패키지 라이선스 보기'),
            ),
          ),
        ],
      ),
    );
  }
}

/// TMDB 사용 사실을 알리는 카드입니다.
/// TMDB가 MovieLog를 보증하는 것처럼 보이지 않도록 정해진 문구를 그대로 씁니다.
class _TmdbAttributionCard extends StatelessWidget {
  const _TmdbAttributionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayLine),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '영화 정보 · TMDB',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.violet),
          ),
          const SizedBox(height: 12),
          // 공식 로고는 색·비율을 바꾸지 않고 너비만 정합니다(MovieLog 로고보다 작게 보입니다).
          Image.asset('assets/logos/tmdb_logo.png', width: 120),
          const SizedBox(height: 16),
          const Text(
            'This product uses the TMDB API but is not endorsed or certified by TMDB.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 10),
          const SelectableText(
            'https://www.themoviedb.org',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
