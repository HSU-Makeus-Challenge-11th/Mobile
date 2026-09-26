import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/popular_movie_card.dart';

class PopularMoviesSection extends StatelessWidget {
  const PopularMoviesSection({super.key, required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '인기 영화',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/movies'),
              child: const Row(
                children: [
                  Text(
                    '전체보기',
                    style: TextStyle(fontSize: 14, color: AppColors.violet),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: AppColors.violet),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return PopularMovieCard(
                movie: movie,
                rank: index + 1,
                onTap: () => context.push('/movies/${movie.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
