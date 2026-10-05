import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/services/fake_movie_service.dart';
import 'package:movielog/widgets/movies/movie_grid.dart';
import 'package:movielog/widgets/movies/movie_list_states.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});
  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final _movieService = const FakeMovieService();
  late Future<List<Movie>> _moviesFuture;
  MovieLoadMode _loadMode = MovieLoadMode.success;
  String genre = '전체';
  final genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러', '로맨스'];

  @override
  void initState() {
    super.initState();
    // build는 여러 번 실행되므로 Future는 여기서 한 번만 만든다
    _moviesFuture = _movieService.fetchMovies(mode: _loadMode);
  }

  /// 새로운 Future를 만들어 Loading부터 다시 시작한다
  void _reload(MovieLoadMode mode) {
    setState(() {
      _loadMode = mode;
      _moviesFuture = _movieService.fetchMovies(mode: mode);
    });
  }

  void _retry() => _reload(MovieLoadMode.success);

  /// 상태별 화면 확인용: 디버그 모드에서 제목을 길게 누르면 불러오기 모드를 고른다
  Future<void> _pickLoadMode() async {
    if (!kDebugMode) return;
    final mode = await showModalBottomSheet<MovieLoadMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (mode, label) in const [
              (MovieLoadMode.success, '성공'),
              (MovieLoadMode.empty, '빈 목록'),
              (MovieLoadMode.failure, '실패'),
            ])
              ListTile(
                title: Text(label),
                trailing: mode == _loadMode ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(mode),
              ),
          ],
        ),
      ),
    );
    if (mode == null || !mounted) return;
    _reload(mode);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onLongPress: _pickLoadMode,
                    child: const Text(
                      '영화',
                      style: TextStyle(
                        fontSize: 22,
                        height: 28 / 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6750A4),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      size: 18,
                      color: Color(0xFF494551),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              height: 40,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 436.19,
                  height: 40,
                  child: Stack(
                    children: [
                      for (var i = 0; i < genres.length; i++)
                        Positioned(
                          left: [0.0, 64.0, 140.0, 194.19, 294.19, 370.19][i],
                          child: SizedBox(
                            width: [55.0, 66.0, 47.0, 88.0, 66.0, 66.0][i],
                            height: 32,
                            child: FilledButton(
                              onPressed: () => setState(() => genre = genres[i]),
                              style: FilledButton.styleFrom(
                                backgroundColor: genre == genres[i]
                                    ? const Color(0xFF6750A4)
                                    : const Color(0xFFE6E0E9),
                                foregroundColor: genre == genres[i]
                                    ? Colors.white
                                    : const Color(0xFF494551),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                genres[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 16 / 12,
                                  fontWeight: genres[i] == 'SF'
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const MovieListLoading();
                }
                // 오류를 먼저 확인해야 실패가 Empty로 보이지 않는다
                if (snapshot.hasError) {
                  return MovieListError(onRetry: _retry);
                }
                final movies = snapshot.data ?? const <Movie>[];
                final visible = genre == '전체'
                    ? movies
                    : movies.where((m) => m.genre.contains(genre)).toList();
                if (visible.isEmpty) return const MovieListEmpty();
                return MovieGrid(movies: visible);
              },
            ),
          ),
        ],
      ),
    );
  }
}
