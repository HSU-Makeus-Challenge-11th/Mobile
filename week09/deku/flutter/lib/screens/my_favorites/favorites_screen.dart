import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/favorite_list_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../view_models/favorites_view_model.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/tmdb_poster_image.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const routeName = '/my/favorites';

  @override
  Widget build(BuildContext context) {
    final model = context.watch<FavoritesViewModel>();
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: '내 즐겨찾기', onBack: () => context.pop()),
      body: switch (model.status) {
        FavoritesStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        FavoritesStatus.empty => const _MessageState(
          key: Key('favorites-empty'),
          icon: Icons.bookmark_border,
          title: '아직 즐겨찾기한 영화가 없습니다.',
          subtitle: '영화 상세에서 북마크를 눌러보세요.',
        ),
        FavoritesStatus.error => _MessageState(
          key: const Key('favorites-error'),
          icon: Icons.error_outline,
          title: '즐겨찾기를 불러오지 못했어요.',
          subtitle: '잠시 후 다시 시도해 주세요.',
          onRetry: model.refresh,
        ),
        FavoritesStatus.success => RefreshIndicator(
          onRefresh: model.refresh,
          child: ListView.separated(
            key: const Key('favorites-list'),
            padding: const EdgeInsets.all(AppSpacing.x2),
            itemCount: model.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.x1),
            itemBuilder: (context, index) => _FavoriteCard(
              item: model.items[index],
              retrying: model.retryingMovieIds.contains(
                model.items[index].favorite.movieId,
              ),
              onRetry: () =>
                  model.retryMovie(model.items[index].favorite.movieId),
              onOpen: () async {
                final movie = model.items[index].movie;
                if (movie == null) return;
                await context.push('/movies/${movie.id}', extra: movie);
                if (context.mounted) {
                  await context.read<FavoritesViewModel>().refresh();
                }
              },
            ),
          ),
        ),
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.item,
    required this.retrying,
    required this.onRetry,
    required this.onOpen,
  });

  final FavoriteListItem item;
  final bool retrying;
  final VoidCallback onRetry;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final movie = item.movie;
    return Card(
      key: ValueKey('favorite-${item.favorite.movieId}'),
      color: AppColors.surfaceBase,
      child: InkWell(
        onTap: movie == null ? null : onOpen,
        borderRadius: AppRadius.medium,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x1),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.medium,
                child: SizedBox(
                  width: 56,
                  height: 80,
                  child: movie == null
                      ? const ColoredBox(
                          color: AppColors.secondary100,
                          child: Icon(Icons.movie_outlined),
                        )
                      : TmdbPosterImage(movie: movie),
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie?.title ?? '영화 #${item.favorite.movieId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLargeMedium,
                    ),
                    const SizedBox(height: AppSpacing.x0_5),
                    if (movie != null)
                      Text(
                        [
                          if (movie.releaseYear != null) '${movie.releaseYear}',
                          movie.genreLabel,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.gray),
                      )
                    else
                      const Text(
                        '영화 정보를 가져오지 못했어요.',
                        style: TextStyle(color: AppColors.gray),
                      ),
                    if (movie == null)
                      TextButton(
                        key: ValueKey('retry-movie-${item.favorite.movieId}'),
                        onPressed: retrying ? null : onRetry,
                        child: Text(retrying ? '불러오는 중…' : '이 영화 다시 시도'),
                      ),
                  ],
                ),
              ),
              if (movie != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: AppColors.primary),
        const SizedBox(height: AppSpacing.x2),
        Text(title, style: AppTextStyles.bodyLargeMedium),
        const SizedBox(height: AppSpacing.x1),
        Text(subtitle, style: const TextStyle(color: AppColors.gray)),
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.x3),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ],
    ),
  );
}
