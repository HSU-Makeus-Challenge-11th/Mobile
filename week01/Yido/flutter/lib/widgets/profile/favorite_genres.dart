import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

/// 선호하는 장르 제목과 장르 Chip 목록.
class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key, required this.genres});

  /// 영문은 Manrope, 한글은 대체 폰트로 그려져 같은 굵기에서도 영문이 얇아 보인다.
  /// 그래서 Figma처럼 한글이 없는 장르(SF 등)는 굵게 표시한다.
  static final _hangul = RegExp('[가-힣]');

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            SvgPicture.asset(
              'assets/logos/movielog_logo.svg',
              width: 20,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.primary500,
                BlendMode.srcIn,
              ),
              semanticsLabel: '장르 아이콘',
            ),
            const Text('선호하는 장르', style: AppTextStyles.bodyLarge),
          ],
        ),
        // 화면이 좁아도 넘치지 않도록 Row 대신 Wrap으로 줄바꿈한다.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres
              .map(
                (genre) => Chip(
                  label: Text(genre),
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    fontWeight: _hangul.hasMatch(genre)
                        ? FontWeight.w500
                        : FontWeight.w700,
                    color: AppColors.primary600,
                  ),
                  backgroundColor: AppColors.primary200,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
