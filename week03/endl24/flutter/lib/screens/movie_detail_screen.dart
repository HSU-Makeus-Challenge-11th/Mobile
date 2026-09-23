import 'package:flutter/material.dart';
import 'package:movielog/models/movie.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(movieId);

    if (movie == null) {
      return const Scaffold(
        body: Center(child: Text('영화를 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  movie.posterAsset,
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                movie.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('${movie.genre} · ${movie.year}'),
            ],
          ),
        ),
      ),
    );
  }
}