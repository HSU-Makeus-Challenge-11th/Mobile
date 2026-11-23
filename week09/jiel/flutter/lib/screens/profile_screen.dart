import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/stat_item.dart';
import '../widgets/top_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: TopAppBar(
        title: '내 프로필',
        actions: [
          // 토큰과 member를 지우고 signedOut으로 바꾸면 Router가 /login으로 보낸다.
          TextButton.icon(
            onPressed: () => context.read<AuthViewModel>().logout(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('로그아웃'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary500),
          ),
        ],
      ),
      body: const ProfileBody(),
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
          SizedBox(height: 32),
          ProfileMenu(),
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
    // GET /v8/members/me 결과(이메일·닉네임)를 구독한다. 수정 성공 시 바로 다시 그려진다.
    final member = context.select<AuthViewModel, ({String nickname, String email})?>(
      (auth) => auth.member == null
          ? null
          : (nickname: auth.member!.nickname, email: auth.member!.email),
    );

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
          member?.nickname ?? '내 정보를 불러오는 중…',
          style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          member?.email ?? '',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        EditProfileButton(enabled: member != null),
      ],
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key, required this.enabled});

  /// 내 정보(member)를 받은 뒤에만 수정 화면으로 이동할 수 있다.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? () => context.push('/my/profile/edit') : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary500,
        side: const BorderSide(color: AppColors.primary500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        minimumSize: const Size(0, 42),
      ),
      child: Text('프로필 수정', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: StatItem(label: '본 영화', value: '342'),
        ),
        SizedBox(width: 8),
        Expanded(
          child: StatItem(label: '평점', value: '4.2'),
        ),
        SizedBox(width: 8),
        Expanded(
          child: StatItem(label: '즐겨찾기', value: '58'),
        ),
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
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final genre in _genres) GenreChip(label: genre)],
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

/// 마이페이지 하단 메뉴. 「내가 등록한 평점」(/my/ratings), 「내 즐겨찾기」(/my/favorites) 행을 탭하면 자식 화면을 push한다.
class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        border: Border.all(color: AppColors.primary200),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _ProfileMenuTile(
            icon: Icons.star_outline_rounded,
            title: '내가 등록한 평점',
            // v7에는 토큰 기반 '내 평점 목록 GET'이 없어 이번 로그인 세션에서 등록한 평점만 보여준다.
            subtitle:
                '이번 로그인에서 등록한 평점 ${context.watch<MyRatingsViewModel>().ratings.length}개',
            onTap: () => context.push('/my/ratings'),
          ),
          const Divider(height: 1, color: AppColors.primary200),
          _ProfileMenuTile(
            icon: Icons.bookmark_border,
            title: '내 즐겨찾기',
            // 내 정보(member)가 준비된 뒤에만 진입할 수 있다. 즐겨찾기 화면이 email로 세션을 구분하기 때문이다.
            onTap: context.select<AuthViewModel, bool>(
                  (auth) => auth.member != null,
                )
                ? () => context.push('/my/favorites')
                : null,
          ),
          // MovieLogButton width 비교 화면은 디버그 빌드에서만 노출한다.
          if (kDebugMode) ...[
            const Divider(height: 1, color: AppColors.primary200),
            _ProfileMenuTile(
              icon: Icons.smart_button_outlined,
              title: '버튼 너비 비교 (개발용)',
              onTap: () => context.push('/dev/buttons'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// null이면 행을 비활성화한다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary500),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: AppColors.onSurface),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.onSurfaceVariant,
      ),
      enabled: onTap != null,
      onTap: onTap,
    );
  }
}
