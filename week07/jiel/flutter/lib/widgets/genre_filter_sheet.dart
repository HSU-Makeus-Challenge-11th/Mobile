import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 여러 장르를 고르는 BottomSheet를 띄운다.
/// 확인을 누르면 선택한 장르를, 그냥 닫으면 null을 돌려준다.
Future<Set<String>?> showGenreFilterSheet(
  BuildContext context, {
  required List<String> genres,
  required Set<String> selected,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    // 하단 탭 바 위까지 덮도록 루트 Navigator에 띄운다.
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) =>
        GenreFilterSheet(genres: genres, initialSelected: selected),
  );
}

class GenreFilterSheet extends StatefulWidget {
  const GenreFilterSheet({
    super.key,
    required this.genres,
    required this.initialSelected,
  });

  final List<String> genres;
  final Set<String> initialSelected;

  @override
  State<GenreFilterSheet> createState() => _GenreFilterSheetState();
}

class _GenreFilterSheetState extends State<GenreFilterSheet> {
  late final Set<String> _selected = {...widget.initialSelected};

  void _toggle(String genre) {
    setState(() {
      if (!_selected.remove(genre)) _selected.add(genre);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 처음엔 화면의 절반 정도(W3-08)로 열리고, 끌어올리면 거의 전체(W3-09)까지 확장된다.
    return DraggableScrollableSheet(
      initialChildSize: 0.51,
      minChildSize: 0.3,
      maxChildSize: 0.87,
      snap: true,
      snapSizes: const [0.51],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // 헤더와 목록을 하나의 스크롤 뷰로 묶어, 어디를 끌어도 시트가 움직이게 한다.
              Expanded(
                child: Scrollbar(
                  controller: scrollController,
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      const SliverToBoxAdapter(child: _SheetHeader()),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        sliver: SliverList.builder(
                          itemCount: widget.genres.length,
                          itemBuilder: (context, index) {
                            final genre = widget.genres[index];
                            return _GenreCheckTile(
                              label: genre,
                              checked: _selected.contains(genre),
                              onTap: () => _toggle(genre),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 확인 버튼은 시트 높이와 상관없이 항상 아래에 고정
              _ConfirmBar(onConfirm: () => Navigator.pop(context, _selected)),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC9C4CF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '장르 필터',
            style: TextStyle(
              fontSize: 20,
              height: 27 / 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF25232A),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '여러 장르를 선택할 수 있어요',
            style: TextStyle(
              fontSize: 14,
              height: 19 / 14,
              color: Color(0xFF6A6571),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreCheckTile extends StatelessWidget {
  const _GenreCheckTile({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _CheckBox(checked: checked),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  height: 22 / 16,
                  color: Color(0xFF25232A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? AppColors.primary500 : AppColors.surfaceBase,
        border: checked
            ? null
            : Border.all(color: const Color(0xFF9A929F), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: checked
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceBase,
        border: Border(top: BorderSide(color: Color(0xFFE6E0EA))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontSize: 16,
                  height: 22 / 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
