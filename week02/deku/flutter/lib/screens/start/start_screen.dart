import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/movie_log_logo.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  static const routeName = '/start';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.x3,
          AppSpacing.x3,
          AppSpacing.x3,
          AppSpacing.x6,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.x3),
                      const Text(
                        'FLUTTER 1주차',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmallMedium,
                      ),
                      const SizedBox(height: AppSpacing.x6),
                      const MovieLogLogo(),
                      const SizedBox(height: AppSpacing.x6),
                      const Text(
                        '영화의 순간을\n기록하세요',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.x1),
                      Text(
                        '보고 싶은 영화부터 나만의 명장면까지\n한곳에서 관리해요',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                      const Spacer(),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary600,
                            foregroundColor: AppColors.white,
                          ),
                          child: const Text('시작하기'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
