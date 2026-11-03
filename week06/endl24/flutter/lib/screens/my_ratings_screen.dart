import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/movie_list_error.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';
import 'package:provider/provider.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '내가 등록한 평점',
        centerTitle: true,
        onBack: () => context.pop(),
      ),
      // bottomNavigationBar는 넣지 않아요 (하단 탭이 없는 화면)
      body: SafeArea(
        child: Consumer<MyRatingsViewModel>(
          builder: (context, viewModel, child) =>
              _buildBody(context, viewModel),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyRatingsViewModel viewModel) {
    return switch (viewModel.status) {
      MyRatingsLoadStatus.idle || MyRatingsLoadStatus.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      MyRatingsLoadStatus.error => MovieListError(
        message: viewModel.message,
        onRetry: viewModel.load,
      ),
      MyRatingsLoadStatus.empty => const Center(child: Text('아직 등록한 평점이 없어요.')),
      MyRatingsLoadStatus.success => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 영화 정보 일부를 못 가져왔을 때의 안내
          if (viewModel.message != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(viewModel.message!, style: AppTextStyles.bodySmall),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.ratings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) =>
                  _RatingCard(entry: viewModel.ratings[index]),
            ),
          ),
        ],
      ),
    };
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});

  final RatingWithMovie entry;

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie; // null일 수 있어요
    final date = rating.createdAt.toLocal();
    final dateText =
        '${date.year}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          // posterPath가 null이면 TmdbPosterImage가 placeholder를 그려요
          child: TmdbPosterImage(
            posterPath: movie?.posterPath,
            width: 60,
            height: 90,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie?.title ?? '영화 #${rating.movieId}', // 영화 정보가 없으면 movieId
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '★ ${rating.score}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.violet,
                ),
              ),
              if (rating.comment != null) ...[
                // comment가 null이면 숨김
                const SizedBox(height: 4),
                Text(rating.comment!, style: AppTextStyles.bodyMedium),
              ],
              const SizedBox(height: 4),
              Text(dateText, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
