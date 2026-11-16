import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/movielog_button.dart';

/// MovieLogButton의 width(null / double.infinity / 고정 값)와
/// 상태(기본 / 통신 중 / 비활성) 차이를 한 화면에서 확인하는 개발용 화면.
/// 마이페이지에서 디버그 빌드일 때만 진입 항목이 보인다.
class ButtonWidthDemoScreen extends StatelessWidget {
  const ButtonWidthDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget caption(String text) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            text,
            style: textTheme.titleSmall?.copyWith(color: AppColors.onSurface),
          ),
        );

    // 버튼이 실제로 차지하는 영역이 보이도록 연한 배경을 깔아 둔다.
    Widget lane(Widget child) => Container(
          color: AppColors.primary100,
          alignment: Alignment.centerLeft,
          child: child,
        );

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('MovieLogButton 비교'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          caption('width: null → 내용(label) 기반 크기'),
          lane(MovieLogButton(label: '중복 확인', onPressed: () {})),
          caption('width: double.infinity → 부모의 최대 너비'),
          lane(MovieLogButton(
            label: '가입하기',
            width: double.infinity,
            onPressed: () {},
          )),
          caption('width: 96 (고정 값) → 항상 같은 크기'),
          lane(MovieLogButton(label: '확인', width: 96, onPressed: () {})),
          lane(MovieLogButton(label: '아주 긴 라벨', width: 96, onPressed: () {})),
          caption('Row 안: 입력창 Expanded + 버튼(width: null), 간격 8'),
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '닉네임',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MovieLogButton(label: '중복 확인', onPressed: () {}),
            ],
          ),
          caption('상태: 기본 / 통신 중(isLoading) / 비활성(onPressed: null)'),
          Row(
            children: [
              MovieLogButton(label: '기본', onPressed: () {}),
              const SizedBox(width: 8),
              MovieLogButton(label: '통신 중', isLoading: true, onPressed: () {}),
              const SizedBox(width: 8),
              const MovieLogButton(label: '비활성', onPressed: null),
            ],
          ),
        ],
      ),
    );
  }
}
