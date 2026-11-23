import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/favorite_list_item.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/load_phase.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/movie_card.dart';
import '../widgets/movielog_button.dart';

/// 내 즐겨찾기 화면(/my/favorites). root Navigator 위에 열리므로 하단 NavigationBar가 없다.
///
/// 목록 / 빈 목록 / 조회 오류 / 영화 정보 한 건 실패를 서로 다른 화면으로 보여 준다.
/// 카드를 눌러 상세에 다녀오면 목록을 다시 조회해, 상세에서 해제한 영화가 사라지게 한다.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.onOpenMovie});

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // build()에서 조회하지 않는다. 첫 프레임 뒤에 한 번만 불러온다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritesViewModel>().refresh();
    });
  }

  Future<void> _openMovie(FavoritesViewModel vm, TmdbMovieDto movie) async {
    await widget.onOpenMovie(movie);
    if (!mounted) return;
    await vm.refresh(); // ViewModel도 같은 현재 세션인지 다시 확인한다.
  }

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
          '내 즐겨찾기',
          style: textTheme.titleLarge?.copyWith(color: AppColors.primary500),
        ),
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, vm, _) {
          return switch (vm.phase) {
            LoadPhase.idle || LoadPhase.loading => const LoadingView(),
            LoadPhase.empty => const EmptyView(message: '아직 즐겨찾기한 영화가 없습니다.'),
            LoadPhase.error => ErrorView(
              message: vm.errorMessage ?? '내 즐겨찾기 목록을 불러오지 못했습니다.',
              onRetry: vm.refresh,
            ),
            LoadPhase.ready => RefreshIndicator(
              color: AppColors.primary500,
              onRefresh: vm.refresh,
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 171 / 316.5,
                ),
                itemCount: vm.items.length,
                itemBuilder: (context, index) {
                  final item = vm.items[index];
                  final movie = item.movie;

                  // 영화 정보를 못 가져온 카드만 placeholder와 재조회 버튼을 보여 준다.
                  if (movie == null) {
                    return _MissingMovieCard(
                      item: item,
                      isRetrying: vm.retryingMovieIds.contains(
                        item.favorite.movieId,
                      ),
                      onRetry: () => vm.retryMovie(item.favorite.movieId),
                    );
                  }

                  return MovieCard(
                    movie: movie,
                    onTap: () => _openMovie(vm, movie),
                  );
                },
              ),
            ),
          };
        },
      ),
    );
  }
}

/// TMDB 영화 정보를 가져오지 못한 즐겨찾기 카드. 다른 카드는 그대로 두고 이 카드만 다시 조회한다.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 2 / 3,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE6E0E9),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: AppColors.neutral800,
                ),
                const SizedBox(height: 12),
                MovieLogButton(
                  label: '정보 재조회',
                  isLoading: isRetrying,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '영화 #${item.favorite.movieId}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        Opacity(
          opacity: 0.8,
          child: Text(
            item.errorMessage ?? '영화 정보가 없습니다.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
