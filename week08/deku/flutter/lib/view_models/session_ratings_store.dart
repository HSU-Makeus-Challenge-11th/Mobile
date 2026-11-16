import 'package:flutter/foundation.dart';

import '../data/models/rating.dart';

/// The v7 API does not provide a token-based endpoint for all of my ratings.
/// Only ratings returned by writes in this login session belong here.
final class SessionRatingsStore extends ChangeNotifier {
  final Map<int, Rating> _ratings = {};

  List<Rating> get ratings => List.unmodifiable(_ratings.values);

  void upsert(Rating rating) {
    _ratings[rating.ratingId] = rating;
    notifyListeners();
  }

  void remove(int ratingId) {
    _ratings.remove(ratingId);
    notifyListeners();
  }

  void clear() {
    if (_ratings.isEmpty) return;
    _ratings.clear();
    notifyListeners();
  }
}
