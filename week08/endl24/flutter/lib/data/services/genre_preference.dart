import 'package:shared_preferences/shared_preferences.dart';

class GenrePreference {
  GenrePreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _selectedGenreIdKey = 'selected_genre_id';

  final SharedPreferencesAsync _preferences;

  Future<int?> read() {
    return _preferences.getInt(_selectedGenreIdKey);
  }

  Future<void> save(int? genreId) async {
    if (genreId == null) {
      await _preferences.remove(_selectedGenreIdKey);
      return;
    }
    await _preferences.setInt(_selectedGenreIdKey, genreId);
  }
}