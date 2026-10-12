import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/models/movie.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE6E0E9)),
    ),
    child: SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MovieLog',
                    style: TextStyle(
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.55,
                      color: Color(0xFF4F378A),
                    ),
                  ),
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        size: 18,
                        color: Color(0xFF4F378A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      height: 72,
                      child: Text(
                        '오늘은 어떤\n영화를 볼까요?',
                        style: TextStyle(
                          fontSize: 28,
                          height: 36 / 28,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -.7,
                          color: Color(0xFF1D1B20),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _Featured(movie: movies.first),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '인기 영화',
                          style: TextStyle(
                            fontSize: 22,
                            height: 28 / 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/movies'),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '전체보기',
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 24 / 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4F378A),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: 8,
                                color: Color(0xFF4F378A),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 272,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: 4,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, i) => i == 3
                          ? const _ComingSoon()
                          : _PopularCard(movie: popularMovies[i], rank: i + 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Featured extends StatelessWidget {
  const _Featured({required this.movie});
  final Movie movie;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/movies/${movie.id}'),
    child: SizedBox(
      width: 356,
      height: 534,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(heroPosterAsset, fit: BoxFit.cover),
            const ColoredBox(color: Color(0xB3000000)),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 75,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xE64F378A),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '추천 신작',
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        letterSpacing: .6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      height: 36 / 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.genre} · ${movie.duration}',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 24 / 16,
                      color: Color(0xFFF8F2FA),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => context.push('/movies/${movie.id}'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4F378A),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 17),
                      label: const Text(
                        '상세보기',
                        style: TextStyle(fontSize: 16, height: 24 / 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.movie, required this.rank});
  final Movie movie;
  final int rank;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/movies/${movie.id}'),
    child: SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  movie.posterAsset,
                  width: 140,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  width: rank == 2
                      ? 26
                      : rank == 3
                      ? 25
                      : 24,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0x99000000),
                    border: Border.all(color: const Color(0x1AFFFFFF)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 24,
            child: Text(
              movie.title,
              style: const TextStyle(
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 16,
            child: Row(
              children: [
                const Icon(Icons.star, size: 11.67, color: Color(0xFFC9A74D)),
                const SizedBox(width: 4),
                Text(
                  '${movie.rating}',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF494551),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 140,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFECE6EE),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Center(
              child: Icon(
                Icons.movie_outlined,
                size: 30,
                color: Color(0xFF494551),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          '개봉 예정작',
          style: TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'D-5',
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4F378A),
          ),
        ),
      ],
    ),
  );
}
