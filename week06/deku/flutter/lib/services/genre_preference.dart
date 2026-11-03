import 'package:shared_preferences/shared_preferences.dart';

abstract interface class GenrePreferenceStore {
  Future<int?> read();

  Future<void> save(int? genreId);
}

final class GenrePreference implements GenrePreferenceStore {
  GenrePreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _selectedGenreKey = 'selected_tmdb_genre_id';

  final SharedPreferencesAsync _preferences;

  @override
  Future<int?> read() => _preferences.getInt(_selectedGenreKey);

  @override
  Future<void> save(int? genreId) {
    if (genreId == null) {
      return _preferences.remove(_selectedGenreKey);
    }
    return _preferences.setInt(_selectedGenreKey, genreId);
  }
}
