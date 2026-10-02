import 'package:movielog/models/movie.dart';
import 'package:movielog/models/movie_sort.dart';

class MovieListInitialData {
  const MovieListInitialData({
    required this.movies,
    required this.selectedGenre,
    required this.selectedSort,
  });

  final List<Movie> movies;
  final String selectedGenre;
  final MovieSort selectedSort;
}