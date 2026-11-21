import 'package:flutter/material.dart';
import 'package:movielog/data/models/favorite_list_item.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/favorites_view_model.dart';
import 'package:movielog/view_models/load_phase.dart';
import 'package:movielog/widgets/favorites/movie_info_card.dart';
import 'package:movielog/widgets/favorites/w9_states.dart';
import 'package:movielog/widgets/w9_app_bar.dart';
import 'package:provider/provider.dart';

/// 내 즐겨찾기(W9). 하단 NavigationBar 없이 root Navigator 위에 뜬다
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.onOpenMovie,
    this.onTitleLongPress,
  });

  /// 상세에서 돌아오면 끝나는 Future. 끝난 뒤 목록을 다시 조회한다
  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;
  final VoidCallback? onTitleLongPress;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritesViewModel>().refresh();
    });
  }

  Future<void> _open(FavoritesViewModel vm, TmdbMovieDto movie) async {
    await widget.onOpenMovie(movie);
    if (!mounted) return;
    await vm.refresh(); // 상세에서 해제했다면 목록에서 사라진다
  }

  Widget _card(FavoritesViewModel vm, FavoriteListItem item) {
    final movie = item.movie;
    final movieId = item.favorite.movieId;
    if (movie == null) {
      return MovieInfoCard(
        key: ValueKey('favorite_$movieId'),
        title: '영화 #$movieId',
        subtitle: 'TMDB 영화 ID $movieId',
        tag: '즐겨찾기한 영화',
        posterFailed: true,
        actionLabel: item.isRetrying ? '불러오는 중…' : '정보 다시 불러오기',
        onAction: item.isRetrying ? null : () => vm.retryMovie(movieId),
      );
    }
    return MovieInfoCard(
      key: ValueKey('favorite_$movieId'),
      title: movie.title,
      subtitle: 'TMDB 영화 ID $movieId',
      tag: '즐겨찾기한 영화',
      posterPath: movie.posterPath,
      onTap: () => _open(vm, movie),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surfaceBright,
    appBar: W9AppBar(
      title: '내 즐겨찾기',
      onTitleLongPress: widget.onTitleLongPress,
    ),
    body: Consumer<FavoritesViewModel>(
      builder: (context, vm, _) => switch (vm.phase) {
        LoadPhase.idle ||
        LoadPhase.loading => const Center(child: CircularProgressIndicator()),
        LoadPhase.empty => const FavoritesEmptyState(),
        LoadPhase.error => W9ErrorState(
          message: vm.errorMessage ?? '즐겨찾기를 불러오지 못했습니다.',
          onRetry: vm.refresh,
        ),
        LoadPhase.ready => RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            itemCount: vm.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 19),
            itemBuilder: (context, index) => _card(vm, vm.items[index]),
          ),
        ),
      },
    ),
  );
}
