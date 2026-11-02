import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/tmdb_poster_image.dart';

/// 마이페이지의 자식 화면. root Navigator 위에 열리므로 하단 NavigationBar가 없다.
class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: AppColors.onSurface,
          onPressed: () => context.pop(),
        ),
        title: Text(
          '내가 등록한 평점',
          style: textTheme.titleLarge?.copyWith(color: AppColors.primary500),
        ),
      ),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, child) {
          return switch (viewModel.status) {
            MyRatingsLoadStatus.idle ||
            MyRatingsLoadStatus.loading => const LoadingView(),
            MyRatingsLoadStatus.empty => const EmptyView(
              message: '아직 등록된 평점이 없어요.',
            ),
            MyRatingsLoadStatus.error => ErrorView(
              message: viewModel.message ?? '평점을 불러오지 못했습니다.',
              onRetry: () => context.read<MyRatingsViewModel>().load(),
            ),
            MyRatingsLoadStatus.success => _RatingList(
              ratings: viewModel.ratings,
              notice: viewModel.message,
              memberId: viewModel.memberId,
            ),
          };
        },
      ),
    );
  }
}

class _RatingList extends StatelessWidget {
  const _RatingList({
    required this.ratings,
    required this.notice,
    required this.memberId,
  });

  final List<RatingWithMovie> ratings;
  final String? notice;
  final int memberId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: ratings.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          // 로그인 기능이 없으므로 "현재 로그인 사용자의 평점"이라고 안내하지 않는다.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '학습용 회원(memberId $memberId)의 공개 평점 ${ratings.length}개',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (notice != null) ...[
                const SizedBox(height: 8),
                Text(
                  notice!,
                  style: textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          );
        }
        return _RatingCard(entry: ratings[index - 1]);
      },
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});

  final RatingWithMovie entry;

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${local.year}.${two(local.month)}.${two(local.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rating = entry.rating;
    final movie = entry.movie;
    final comment = rating.comment;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        border: Border.all(color: AppColors.primary200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // movie가 null이면 posterPath도 null → TmdbPosterImage가 placeholder를 그린다.
            child: TmdbPosterImage(
              posterPath: movie?.posterPath,
              width: 64,
              height: 96,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie?.title ?? '영화 정보를 불러오지 못했어요',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: movie == null
                        ? AppColors.neutral800
                        : AppColors.onSurface,
                  ),
                ),
                if (movie == null)
                  Text(
                    'movieId ${rating.movieId}',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.neutral800,
                    ),
                  ),
                const SizedBox(height: 6),
                _ScoreStars(score: rating.score),
                // comment가 null(또는 빈 문자열)이면 표시하지 않는다.
                if (comment != null && comment.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    comment,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  _formatDate(rating.createdAt),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreStars extends StatelessWidget {
  const _ScoreStars({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= score ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18,
            color: AppColors.tertiary200,
          ),
        const SizedBox(width: 6),
        Text(
          '$score',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
