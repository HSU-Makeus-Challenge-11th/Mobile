import 'package:shared_preferences/shared_preferences.dart';

/// 마지막으로 선택한 장르처럼 중요하지 않은 설정값만 저장한다
class GenrePreference {
  GenrePreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const selectedGenreKey = 'selected_genre';
  static const defaultGenre = '전체';

  final SharedPreferencesAsync _preferences;

  Future<String> read() async =>
      await _preferences.getString(selectedGenreKey) ?? defaultGenre;

  Future<void> save(String genre) =>
      _preferences.setString(selectedGenreKey, genre);

  Future<void> clear() => _preferences.remove(selectedGenreKey);
}
