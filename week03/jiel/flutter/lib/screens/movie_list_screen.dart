import 'package:flutter/material.dart';
import '../data/mock/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/top_app_bar.dart';

const _genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러', '로맨스'];

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String _selectedGenre = _genres.first;

  List<Movie> get _filteredMovies => _selectedGenre == '전체'
      ? movies
      : movies.where((movie) => movie.genre == _selectedGenre).toList();

  @override
  Widget build(BuildContext context) {
    final filteredMovies = _filteredMovies;

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: const TopAppBar(title: '영화'),
      body: CustomScrollView(
        slivers: [
          // 1. 장르 필터 칩 (가로 스크롤)
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _genres.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final genre = _genres[index];
                    return Center(
                      child: _GenreChip(
                        label: genre,
                        selected: genre == _selectedGenre,
                        onTap: () => setState(() => _selectedGenre = genre),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // 2. 영화 그리드 (2열)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 171 / 316.5,
              ),
              itemCount: filteredMovies.length,
              itemBuilder: (context, index) =>
                  _MovieGridItem(movie: filteredMovies[index]),
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
  const _MovieGridItem({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Column(
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
