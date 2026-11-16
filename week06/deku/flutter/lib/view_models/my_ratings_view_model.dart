import 'package:flutter/foundation.dart';

import '../data/models/rating.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

enum MyRatingsStatus { idle, loading, empty, error, success }

final class MyRatingItem {
  const MyRatingItem({required this.rating, required this.movie});

  final Rating rating;
  final TmdbMovieDto movie;
}

final class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._ratingApiService, this._movieService);

  final RatingApiService _ratingApiService;
  final MovieService _movieService;

  MyRatingsStatus status = MyRatingsStatus.idle;
  List<MyRatingItem> items = const [];

  Future<void> load({int memberId = 1}) async {
    status = MyRatingsStatus.loading;
    items = const [];
    notifyListeners();

    try {
      final ratings = await _ratingApiService.fetchMyRatings(memberId);
      if (ratings.isEmpty) {
        status = MyRatingsStatus.empty;
        notifyListeners();
        return;
      }

      items = await Future.wait(ratings.map(_enrichRating));
      status = MyRatingsStatus.success;
    } catch (_) {
      status = MyRatingsStatus.error;
      items = const [];
    }
    notifyListeners();
  }

  Future<MyRatingItem> _enrichRating(Rating rating) async {
    try {
      final movie = await _movieService.fetchMovieById(rating.movieId);
      return MyRatingItem(rating: rating, movie: movie);
    } catch (_) {
      return MyRatingItem(
        rating: rating,
        movie: TmdbMovieDto(id: rating.movieId, title: '영화 #${rating.movieId}'),
      );
    }
  }
}
