import 'package:shared_preferences/shared_preferences.dart';

import 'mock/movie.dart';

const _selectedGenresKey = 'last_selected_genres';
final _prefs = SharedPreferencesAsync();

/// 마지막으로 선택한 장르를 불러온다. 지금 장르 목록에 없는 값은 버린다.
Future<Set<String>> loadSelectedGenres() async {
  final saved = await _prefs.getStringList(_selectedGenresKey) ?? const [];
  return saved.where(genres.contains).toSet();
}

Future<void> saveSelectedGenres(Set<String> selected) =>
    _prefs.setStringList(_selectedGenresKey, selected.toList());
