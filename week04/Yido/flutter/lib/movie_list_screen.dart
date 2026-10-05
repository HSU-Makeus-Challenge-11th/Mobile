import 'package:flutter/material.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/widgets/movies/movie_grid.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});
  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String genre = '전체';
  final genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러', '로맨스'];
  @override
  Widget build(BuildContext context) {
    final visible = genre == '전체'
        ? movies
        : movies.where((m) => m.genre.contains(genre)).toList();
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
                  const Text(
                    '영화',
                    style: TextStyle(
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6750A4),
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
          Expanded(child: MovieGrid(movies: visible)),
        ],
      ),
    );
  }
}
