import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/common_app_bar.dart';
import '../widgets/edit_profile_button.dart';
import '../widgets/favorite_genres.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ProfileHeader(),
            const SizedBox(height: 24),
            const EditProfileButton(),
            const SizedBox(height: 24),
            const ProfileStats(),
            const SizedBox(height: 24),
            const FavoriteGenres(genres: ['드라마', 'SF', '애니메이션']),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('내가 등록한 평점'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/my/ratings'),
            ),
          ],
        ),
      ),
    );
  }
}
