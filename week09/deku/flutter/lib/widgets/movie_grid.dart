import 'package:flutter/material.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_dimensions.dart';
import 'movie_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies, this.footer});

  final List<TmdbMovieDto> movies;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('movie-list-scroll-view'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x2,
            AppSpacing.x2,
            AppSpacing.x2,
            AppSpacing.x2,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.x2,
              mainAxisSpacing: AppSpacing.x3,
              mainAxisExtent: 316.5,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) => MovieCard(movie: movies[index]),
          ),
        ),
        if (footer != null) SliverToBoxAdapter(child: footer),
      ],
    );
  }
}
