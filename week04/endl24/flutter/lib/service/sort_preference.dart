import 'package:movielog/models/movie_sort.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SortPreference {
  SortPreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _selectedSortKey = 'selected_sort';

  final SharedPreferencesAsync _preferences;

  Future<MovieSort> read() async {
    final name = await _preferences.getString(_selectedSortKey);
    return MovieSort.values.asNameMap()[name] ?? MovieSort.latest;
  }

  Future<void> save(MovieSort sort) async {
    await _preferences.setString(_selectedSortKey, sort.name);
  }
}