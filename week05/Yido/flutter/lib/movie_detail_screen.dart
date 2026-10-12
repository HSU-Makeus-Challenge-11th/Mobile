import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/widgets/movies/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});
  final String movieId;
  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool favorite = false;
  double? rating;
  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(widget.movieId);
    if (movie == null) {
      return const Scaffold(body: Center(child: Text('영화를 찾을 수 없습니다.')));
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            size: 16,
            color: Color(0xFF6750A4),
          ),
        ),
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6750A4),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.ios_share,
              size: 18,
              color: Color(0xFF494551),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 81),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              movie.id == 'starlight' ? heroPosterAsset : movie.posterAsset,
              width: double.infinity,
              height: 585,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      height: 36 / 28,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B1C1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.year} • ${movie.genre} • ${movie.duration}',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      letterSpacing: .25,
                      color: Color(0xFF494551),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: 4.5,
                        itemCount: 5,
                        itemSize: 16.67,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: Color(0xFF6750A4)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '4.5',
                        style: TextStyle(
                          fontSize: 16,
                          height: 24 / 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '(1,245)',
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color(0xFF494551),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 20),
                  Row(
                    children: movie.id == 'starlight'
                        ? const [
                            _GenreChip('로맨스'),
                            SizedBox(width: 8),
                            _GenreChip('드라마'),
                            SizedBox(width: 8),
                            _GenreChip('감동적인'),
                          ]
                        : [_GenreChip(movie.genre)],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFCBC4D2))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '시놉시스',
                    style: TextStyle(
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    movie.synopsis.split('\n\n').length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index == movie.synopsis.split('\n\n').length - 1
                            ? 0
                            : 26,
                      ),
                      child: SizedBox(
                        width: [330.0, 328.0, 329.0, 330.0][index.clamp(0, 3)],
                        child: Text(
                          movie.synopsis.split('\n\n')[index],
                          style: const TextStyle(
                            fontSize: 16,
                            height: 26 / 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: .5,
                            color: Color(0xFF494551),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 81,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFFAF9F5),
          border: Border(top: BorderSide(color: Color(0xFFCBC4D2))),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final favoriteWidth = (constraints.maxWidth - 8) * 176 / 350;
            final ratingWidth = (constraints.maxWidth - 8) * 174 / 350;
            return Row(
              children: [
                SizedBox(
                  width: favoriteWidth,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => favorite = !favorite);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            favorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 제거했습니다.',
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      favorite ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                    ),
                    label: const Text('즐겨찾기'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: ratingWidth,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      barrierColor: const Color(0x7A000000),
                      builder: (_) => RatingDialog(
                        onSaved: (v) {
                          setState(() => rating = v);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${v.toStringAsFixed(1)}점을 저장했습니다.',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    icon: const Icon(Icons.star, size: 20),
                    label: Text(
                      rating == null
                          ? '평점 남기기'
                          : '${rating!.toStringAsFixed(1)}점',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    height: 28,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFE3E2DF),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        letterSpacing: .1,
        color: Color(0xFF494551),
      ),
    ),
  );
}
