import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/widgets/hero_movie_card.dart';
import 'package:movielog/widgets/home_greeting.dart';
import 'package:movielog/widgets/popular_movies_section.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final heroMovie = mockMovies.first;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeGreeting(),
              const SizedBox(height: 16),
              HeroMovieCard(
                movie: heroMovie,
                onTap: () => context.push('/movies/${heroMovie.id}'),
              ),
              const SizedBox(height: 32),
              Consumer<MovieHomeViewModel>(
                builder: (context, viewModel, child) {
                  return switch (viewModel.status) {
                    MovieHomeLoadStatus.idle ||
                    MovieHomeLoadStatus.loading => const _PopularStatusBox(
                      child: CircularProgressIndicator(),
                    ),
                    MovieHomeLoadStatus.empty => const _PopularStatusBox(
                      child: Text('인기 영화가 없어요.'),
                    ),
                    MovieHomeLoadStatus.error => _PopularStatusBox(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(viewModel.message ?? '인기 영화를 불러오지 못했어요.'),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context
                                .read<MovieHomeViewModel>()
                                .loadPopular(),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    ),
                    MovieHomeLoadStatus.success => PopularMoviesSection(
                      movies: viewModel.popularMovies,
                    ),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularStatusBox extends StatelessWidget {
  const _PopularStatusBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(child: child),
    );
  }
}