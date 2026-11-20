import 'package:flutter/material.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/widgets/movies/movie_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({
    super.key,
    required this.movies,
    this.genreNames = const {},
    this.footer,
    this.controller,
  });
  final List<TmdbMovieDto> movies;
  final Map<int, String> genreNames;

  /// 카드 아래에 이어 붙이는 위젯(더 보기·재시도·끝 안내)
  final Widget? footer;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final itemWidth = (constraints.maxWidth - 48) / 2;
      return CustomScrollView(
        controller: controller,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, footer == null ? 96 : 24),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: itemWidth / (itemWidth * 1.5 + 60),
              ),
              itemCount: movies.length,
              itemBuilder: (context, i) => MovieCard(
                movie: movies[i],
                genreNames: [
                  for (final id in movies[i].genreIds) ?genreNames[id],
                ],
              ),
            ),
          ),
          if (footer != null)
            SliverPadding(
              // W9: 버튼은 좌우 24, 아래 NavigationBar에 가리지 않게 띄운다
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
              sliver: SliverToBoxAdapter(child: footer),
            ),
        ],
      );
    },
  );
}
