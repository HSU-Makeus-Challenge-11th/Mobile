import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/widgets/hero_movie_card.dart';
import 'package:movielog/widgets/home_greeting.dart';
import 'package:movielog/widgets/popular_movies_section.dart';

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
              PopularMoviesSection(movies: mockMovies.skip(1).toList()),
            ],
          ),
        ),
      ),
    );
  }
}