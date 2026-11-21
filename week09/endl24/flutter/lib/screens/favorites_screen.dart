import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/favorite_list_item.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/favorites_view_model.dart';
import 'package:movielog/view_models/load_phase.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';
import 'package:provider/provider.dart';

/// 마이페이지 → 내 즐겨찾기 화면입니다(하단 탭 없음).
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.onOpenMovie});

  /// 카드를 누르면 영화 상세로 이동합니다. 상세에서 돌아오면 Future가 끝납니다.
  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 만들어질 때 한 번 조회합니다(build에서는 조회하지 않습니다).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritesViewModel>().refresh();
    });
  }

  Future<void> _openMovie(FavoritesViewModel vm, TmdbMovieDto movie) async {
    await widget.onOpenMovie(movie);
    if (!mounted) return;
    // 상세에서 즐겨찾기를 해제했을 수 있으니 목록을 다시 조회합니다.
    await vm.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '내 즐겨찾기',
        centerTitle: true,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: Consumer<FavoritesViewModel>(
          builder: (context, vm, _) => switch (vm.phase) {
            LoadPhase.idle || LoadPhase.loading => const Center(
              child: CircularProgressIndicator(color: AppColors.violet),
            ),
            LoadPhase.empty => _EmptyOrError(
              message: '아직 즐겨찾기한 영화가 없습니다.',
              onRefresh: vm.refresh,
            ),
            LoadPhase.error => _EmptyOrError(
              message: vm.errorMessage ?? '내 즐겨찾기 목록을 불러오지 못했습니다.',
              buttonLabel: '다시 시도',
              onRefresh: vm.refresh,
            ),
            LoadPhase.ready => RefreshIndicator(
              color: AppColors.violet,
              onRefresh: vm.refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                // 목록이 있는 상태에서 새로고침이 실패하면 맨 위에 안내 한 줄을 둡니다.
                itemCount: vm.items.length + (vm.errorMessage != null ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (vm.errorMessage != null) {
                    if (index == 0) {
                      return Text(
                        '${vm.errorMessage} 아래로 당겨 다시 시도해 주세요.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.red,
                        ),
                      );
                    }
                    index -= 1;
                  }
                  final item = vm.items[index];
                  final movie = item.movie;
                  return movie == null
                      ? _MissingMovieCard(
                          item: item,
                          isRetrying: vm.retryingIds.contains(
                            item.favorite.favoriteId,
                          ),
                          onRetry: () =>
                              vm.retryMovie(item.favorite.favoriteId),
                        )
                      : _FavoriteMovieCard(
                          item: item,
                          movie: movie,
                          onTap: () => _openMovie(vm, movie),
                        );
                },
              ),
            ),
          },
        ),
      ),
    );
  }
}

/// 빈 결과와 첫 조회 오류 화면입니다.
class _EmptyOrError extends StatelessWidget {
  const _EmptyOrError({
    required this.message,
    required this.onRefresh,
    this.buttonLabel = '새로고침',
  });

  final String message;
  final String buttonLabel;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grayDark),
          ),
          const SizedBox(height: 16),
          MovieLogButton(label: buttonLabel, width: 180, onPressed: onRefresh),
        ],
      ),
    );
  }
}

String _dateText(DateTime dateTime) {
  final date = dateTime.toLocal();
  return '${date.year}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.day.toString().padLeft(2, '0')}';
}

class _FavoriteMovieCard extends StatelessWidget {
  const _FavoriteMovieCard({
    required this.item,
    required this.movie,
    required this.onTap,
  });

  final FavoriteListItem item;
  final TmdbMovieDto movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final year = movie.releaseDate?.split('-').first;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TmdbPosterImage(
              posterPath: movie.posterPath,
              width: 60,
              height: 90,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title, style: AppTextStyles.titleMedium),
                if (year != null && year.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(year, style: AppTextStyles.bodySmall),
                ],
                const SizedBox(height: 4),
                Text(
                  '${_dateText(item.favorite.createdAt)} 즐겨찾기',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gray),
        ],
      ),
    );
  }
}

/// TMDB 영화 정보를 가져오지 못한 카드입니다. 이 카드만 다시 조회할 수 있습니다.
class _MissingMovieCard extends StatelessWidget {
  const _MissingMovieCard({
    required this.item,
    required this.isRetrying,
    required this.onRetry,
  });

  final FavoriteListItem item;
  final bool isRetrying;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          // posterPath가 null이면 placeholder를 그립니다.
          child: const TmdbPosterImage(posterPath: null, width: 60, height: 90),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '영화 #${item.favorite.movieId}',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                item.errorMessage ?? '영화 정보가 없습니다.',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        MovieLogButton(
          label: '정보 재조회',
          width: 110,
          height: 36,
          isLoading: isRetrying,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
