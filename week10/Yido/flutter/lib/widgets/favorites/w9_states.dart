import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:movielog/widgets/favorites/bookmark_icon.dart';
import 'package:movielog/widgets/movielog_button.dart';

TextStyle _w9(double size, double line, FontWeight weight, Color color) =>
    w8Text(size, weight, color).copyWith(height: line / size);

/// W9 조회 오류: 문구 16/22와 222x44 다시 시도 버튼
class W9ErrorState extends StatelessWidget {
  const W9ErrorState({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: _w9(16, 22, FontWeight.w700, AppColors.mutedText),
        ),
        const SizedBox(height: 29),
        MovieLogButton(
          key: const Key('w9RetryButton'),
          label: '다시 시도',
          width: 222,
          labelStyle: _w9(14, 19, FontWeight.w700, AppColors.white),
          onPressed: onRetry,
        ),
      ],
    ),
  );
}

/// W9 내 즐겨찾기 빈 결과: 북마크와 두 줄 안내
class FavoritesEmptyState extends StatelessWidget {
  const FavoritesEmptyState({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BookmarkIcon(filled: false),
        const SizedBox(height: 45),
        Text(
          '아직 즐겨찾기한 영화가 없습니다.',
          style: _w9(17, 23, FontWeight.w700, AppColors.mutedText),
        ),
        const SizedBox(height: 14),
        Text(
          '영화 상세에서 북마크를 눌러보세요.',
          style: _w9(13, 18, FontWeight.w400, AppColors.mutedText),
        ),
      ],
    ),
  );
}

/// W9 검색 빈 결과
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key, this.message = '검색 결과가 없습니다.'});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: _w9(18, 25, FontWeight.w700, AppColors.mutedText),
    ),
  );
}
