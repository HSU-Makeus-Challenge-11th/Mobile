import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';

class MovieListEmpty extends StatelessWidget {
  const MovieListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: Key('movie-list-empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_filter_outlined, size: 48, color: AppColors.gray),
          SizedBox(height: AppSpacing.x2),
          Text('보여드릴 영화가 없어요', style: AppTextStyles.bodyLargeMedium),
          SizedBox(height: AppSpacing.x1),
          Text('다른 장르를 선택해 보세요.', style: TextStyle(color: AppColors.gray)),
        ],
      ),
    );
  }
}
