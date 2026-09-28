import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'widgets/stat_item.dart';
import 'widgets/top_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: TopAppBar(title: '내 프로필'),
      body: ProfileBody(),
    );
  }
}

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(),
          SizedBox(height: 32),
          ProfileStats(),
          SizedBox(height: 32),
          FavoriteGenres(),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary300, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile/profile_movielog.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '무비러버',
          style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        const EditProfileButton(),
      ],
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary500,
        side: const BorderSide(color: AppColors.primary500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        minimumSize: const Size(0, 42),
      ),
      child: Text(
        '프로필 수정',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: StatItem(label: '본 영화', value: '342')),
        SizedBox(width: 8),
        Expanded(child: StatItem(label: '평점', value: '4.2')),
        SizedBox(width: 8),
        Expanded(child: StatItem(label: '즐겨찾기', value: '58')),
      ],
    );
  }
}

class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key});

  static const _genres = ['드라마', 'SF', '애니메이션'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '선호하는 장르',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final genre in _genres) GenreChip(label: genre),
          ],
        ),
      ],
    );
  }
}

class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary200,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          // 디자인상 SF만 bold
          fontWeight: label == 'SF' ? FontWeight.w700 : null,
          color: AppColors.primary600,
        ),
      ),
    );
  }
}
