import 'package:flutter/material.dart';

import '../../data/mock_movies.dart';
import '../../models/movie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  static const routeName = '/movies';

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String _selectedGenre = '전체';

  List<Movie> get _filteredMovies => _selectedGenre == '전체'
      ? movies
      : movies.where((movie) => movie.genre == _selectedGenre).toList();

  @override
  Widget build(BuildContext context) {
    final genres = ['전체', ...movieGenres];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Text(
          '영화',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            tooltip: '검색',
            onPressed: () {},
            icon: const Icon(Icons.search, size: 18),
          ),
          const SizedBox(width: AppSpacing.x1),
        ],
      ),
      body: CustomScrollView(
        key: const Key('movie-list-scroll-view'),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x2,
                  AppSpacing.x1,
                  AppSpacing.x2,
                  AppSpacing.x1,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: genres.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.x1),
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  return ChoiceChip(
                    key: ValueKey('genre-filter-$genre'),
                    label: Text(genre),
                    selected: genre == _selectedGenre,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.secondary100,
                    labelStyle: AppTextStyles.labelSmallMedium.copyWith(
                      color: genre == _selectedGenre
                          ? AppColors.white
                          : AppColors.profileOnSurfaceVariant,
                    ),
                    side: BorderSide.none,
                    onSelected: (_) => setState(() => _selectedGenre = genre),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2,
              AppSpacing.x2,
              AppSpacing.x2,
              AppSpacing.x2,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.x2,
                mainAxisSpacing: AppSpacing.x3,
                mainAxisExtent: 316.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => MovieCard(movie: _filteredMovies[index]),
                childCount: _filteredMovies.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
