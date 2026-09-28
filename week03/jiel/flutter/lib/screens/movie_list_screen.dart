import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/genre_filter_sheet.dart';
import '../widgets/top_app_bar.dart';

const _allLabel = '전체';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  // 비어 있으면 '전체'. Chip과 BottomSheet가 같은 선택 상태를 공유한다.
  Set<String> _selectedGenres = {};

  List<Movie> get _filteredMovies => _selectedGenres.isEmpty
      ? movies
      : movies.where((movie) => _selectedGenres.contains(movie.genre)).toList();

  void _onChipTap(String label) {
    setState(() {
      if (label == _allLabel) {
        _selectedGenres = {};
        return;
      }
      // 이미 선택된 장르면 해제, 아니면 추가
      final next = {..._selectedGenres};
      if (!next.remove(label)) next.add(label);
      _selectedGenres = next;
    });
  }

  Future<void> _openFilterSheet() async {
    final result = await showGenreFilterSheet(
      context,
      genres: genres,
      selected: _selectedGenres,
    );
    if (!mounted || result == null) return;
    setState(() => _selectedGenres = result);
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = _filteredMovies;
    const chipLabels = [_allLabel, ...genres];

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: TopAppBar(
        title: '영화',
        actions: [
          IconButton(
            onPressed: _openFilterSheet,
            tooltip: '장르 필터',
            icon: const Icon(Icons.filter_list),
            color: AppColors.primary500,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 장르 필터 칩 (가로 ListView)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: chipLabels.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final label = chipLabels[index];
                  final selected = label == _allLabel
                      ? _selectedGenres.isEmpty
                      : _selectedGenres.contains(label);
                  return Center(
                    child: _GenreChip(
                      label: label,
                      selected: selected,
                      onTap: () => _onChipTap(label),
                    ),
                  );
                },
              ),
            ),
          ),
          // 2. 영화 그리드 (2열 GridView)
          Expanded(
            child: filteredMovies.isEmpty
                ? const Center(
                    child: Text(
                      '해당 장르의 영화가 없어요.',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                          childAspectRatio: 171 / 316.5,
                        ),
                    itemCount: filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = filteredMovies[index];
                      return _MovieGridItem(
                        movie: movie,
                        onTap: () => context.push('/movie/${movie.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary500 : const Color(0xFFE6E0E9),
          borderRadius: BorderRadius.circular(9999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MovieGridItem extends StatelessWidget {
  const _MovieGridItem({required this.movie, required this.onTap});

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E0E9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(movie.posterAsset, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _RatingBadge(rating: movie.rating),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            movie.title,
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
              '${movie.year} · ${movie.genre}',
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
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF322F35).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '★ ${rating.toStringAsFixed(1)}',
        style: const TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF5EFF7),
        ),
      ),
    );
  }
}
