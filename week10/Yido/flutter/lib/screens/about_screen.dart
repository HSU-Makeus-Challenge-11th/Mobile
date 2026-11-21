import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/about_view_model.dart';
import 'package:movielog/widgets/w9_app_bar.dart';
import 'package:provider/provider.dart';

/// 앱 정보(W10 앱 정보·출처 안내). 하단 NavigationBar 없이 root Navigator 위에 뜬다
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const routePath = '/my/about';

  /// TextStyle을 새로 만들지 않고 1주차 AppTextStyles에서 크기·굵기·색만 바꾼다
  static TextStyle _style(
    double size,
    double line,
    FontWeight weight,
    Color color,
  ) => AppTextStyles.bodyLarge.copyWith(
    fontSize: size,
    height: line / size,
    fontWeight: weight,
    color: color,
  );

  @override
  Widget build(BuildContext context) {
    final versionLabel = context.watch<AboutViewModel>().versionLabel;
    final disclaimer = _style(12, 16, FontWeight.w400, AppColors.mutedText);
    return Scaffold(
      backgroundColor: AppColors.surfaceBright,
      appBar: const W9AppBar(title: '앱 정보'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 68, 24, 32),
        children: [
          Center(
            child: Image.asset(
              'assets/logos/movielog_logo.png',
              key: const Key('aboutMovieLogLogo'),
              width: 58,
            ),
          ),
          const SizedBox(height: 46),
          Text(
            'MovieLog',
            textAlign: TextAlign.center,
            style: _style(26, 36, FontWeight.w700, AppColors.ink),
          ),
          const SizedBox(height: 11),
          Text(
            '버전 $versionLabel',
            key: const Key('aboutVersion'),
            textAlign: TextAlign.center,
            style: _style(14, 19, FontWeight.w400, AppColors.mutedText),
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 27),
            decoration: BoxDecoration(
              color: AppColors.surfaceBright,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '영화 정보 · TMDB',
                  style: _style(18, 25, FontWeight.w700, AppColors.primary500),
                ),
                const SizedBox(height: 10),
                // TMDB 로고는 비율·색을 바꾸지 않고, MovieLog 로고보다 크게 보이지 않게 둔다
                Image.asset(
                  'assets/logos/tmdb_logo.png',
                  key: const Key('aboutTmdbLogo'),
                  width: 120,
                  semanticLabel: 'TMDB',
                ),
                const SizedBox(height: 20),
                Semantics(
                  label: 'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Text('This product uses the TMDB API', style: disclaimer),
                      Text(
                        'but is not endorsed or certified',
                        style: disclaimer,
                      ),
                      Text('by TMDB.', style: disclaimer),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          Text(
            '오픈소스 라이선스',
            style: _style(17, 23, FontWeight.w700, AppColors.ink),
          ),
          const SizedBox(height: 15),
          Text(
            'Manrope · Material Symbols',
            style: _style(13, 18, FontWeight.w400, AppColors.mutedText),
          ),
          const SizedBox(height: 35),
          Text(
            '영화 데이터·이미지 출처를 확인합니다.',
            style: _style(14, 19, FontWeight.w400, AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
