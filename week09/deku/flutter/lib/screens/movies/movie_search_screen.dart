import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../view_models/paged_movies_view_model.dart';
import '../../widgets/movie_grid.dart';
import 'widgets/movie_page_footer.dart';

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  static const routeName = '/movies/search';

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<PagedMoviesViewModel>().submitSearch(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PagedMoviesViewModel>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '뒤로 가기',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('영화 검색'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.x2),
            child: TextField(
              key: const Key('movie-search-field'),
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: '영화 제목을 입력하세요',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  key: const Key('movie-search-submit'),
                  tooltip: '검색',
                  onPressed: _submit,
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: switch (model.status) {
              PageLoadStatus.idle => const _SearchMessage(
                key: Key('search-idle'),
                icon: Icons.search,
                message: '영화 제목을 검색해 보세요.',
              ),
              PageLoadStatus.initialLoading => const Center(
                child: CircularProgressIndicator(),
              ),
              PageLoadStatus.empty => const _SearchMessage(
                key: Key('search-empty'),
                icon: Icons.search_off,
                message: '검색 결과가 없어요.',
              ),
              PageLoadStatus.error => Center(
                key: const Key('search-error'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('검색 결과를 불러오지 못했어요.'),
                    const SizedBox(height: AppSpacing.x2),
                    FilledButton(
                      onPressed: model.retryFirst,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
              PageLoadStatus.success => MovieGrid(
                movies: model.movies,
                footer: MoviePageFooter(model: model),
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: AppColors.primary),
        const SizedBox(height: AppSpacing.x2),
        Text(message),
      ],
    ),
  );
}
