import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/load_phase.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/movie_page_footer.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';
import 'package:provider/provider.dart';

/// 영화 제목 검색 화면입니다(하단 탭 없음).
/// 영화 목록과는 별도의 PagedMoviesViewModel 인스턴스를 씁니다.
class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key, required this.onOpenMovie});

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final _controller = TextEditingController();
  String? _inputError;

  /// 제출(키보드 검색 버튼·돋보기)할 때만 요청합니다. 글자를 입력할 때마다 요청하지 않습니다.
  void _submitSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      // 빈 검색어는 서버에 보내지 않습니다.
      setState(() => _inputError = '검색어를 입력해 주세요.');
      return;
    }
    setState(() => _inputError = null);
    FocusScope.of(context).unfocus();
    // 새 검색은 이전 결과를 비우고 page 1부터 시작합니다.
    context.read<PagedMoviesViewModel>().loadInitial(query: query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '영화 검색',
        centerTitle: true,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: _submitSearch,
                decoration: InputDecoration(
                  hintText: '영화 제목을 입력하세요',
                  hintStyle: AppTextStyles.bodySmall,
                  errorText: _inputError,
                  filled: true,
                  fillColor: AppColors.grayLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    tooltip: '검색',
                    icon: const Icon(Icons.search, color: AppColors.violet),
                    onPressed: () => _submitSearch(_controller.text),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<PagedMoviesViewModel>(
                builder: (context, vm, _) => _buildBody(vm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PagedMoviesViewModel vm) {
    return switch (vm.phase) {
      // 처음 들어온 상태(idle)와 결과 없음(empty)을 구분합니다.
      LoadPhase.idle => const _Message('보고 싶은 영화의 제목을 검색해 보세요.'),
      LoadPhase.loading => const Center(
        child: CircularProgressIndicator(color: AppColors.violet),
      ),
      LoadPhase.empty => _Message('"${vm.query}"에 대한 검색 결과가 없습니다.'),
      LoadPhase.error => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Message(vm.errorMessage ?? '검색 결과를 불러오지 못했습니다.'),
            const SizedBox(height: 16),
            MovieLogButton(
              label: '다시 시도',
              width: 180,
              onPressed: vm.retryInitial,
            ),
          ],
        ),
      ),
      LoadPhase.ready => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: vm.movies.length + 1, // 마지막 칸은 더 보기 footer
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == vm.movies.length) return MoviePageFooter(vm: vm);
          final movie = vm.movies[index];
          return _SearchResultCard(
            movie: movie,
            onTap: () => widget.onOpenMovie(movie),
          );
        },
      ),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grayDark),
        ),
      ),
    );
  }
}

/// 검색 결과 카드(가로형)입니다. 누르면 영화 상세로 이동합니다.
class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.movie, required this.onTap});

  final TmdbMovieDto movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final year = movie.releaseDate?.split('-').first;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TmdbPosterImage(
              posterPath: movie.posterPath,
              width: 60,
              height: 90,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title, style: AppTextStyles.titleMedium),
                if (year != null && year.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(year, style: AppTextStyles.bodySmall),
                ],
                const SizedBox(height: 4),
                Text(
                  '★ ${movie.voteAverage.toStringAsFixed(1)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.violet,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gray),
        ],
      ),
    );
  }
}
