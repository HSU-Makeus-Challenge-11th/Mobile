import 'package:shared_preferences/shared_preferences.dart';

abstract interface class GenrePreferenceStore {
  Future<String> read();

  Future<void> save(String genre);
}

final class GenrePreference implements GenrePreferenceStore {
  GenrePreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const defaultGenre = '전체';
  static const _selectedGenreKey = 'selected_genre';

  final SharedPreferencesAsync _preferences;

  @override
  Future<String> read() async {
    return await _preferences.getString(_selectedGenreKey) ?? defaultGenre;
  }

  @override
  Future<void> save(String genre) {
    return _preferences.setString(_selectedGenreKey, genre);
  }
}
