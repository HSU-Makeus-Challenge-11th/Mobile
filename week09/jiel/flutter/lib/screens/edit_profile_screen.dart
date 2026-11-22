import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../widgets/movielog_button.dart';

/// 프로필 수정(/my/profile/edit). 이메일은 읽기 전용, 닉네임만 PATCH /v7/members/me로 수정한다.
/// - 성공: AuthViewModel.member 교체 → Snackbar → 마이페이지 복귀
/// - 입력/중복 오류: 화면에 남아 필드 아래 오류(입력값 유지)
/// - 401: 세션 정리 → Router가 /login
/// - 네트워크 오류: Snackbar, 로그아웃 없음
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final member = context.read<AuthViewModel>().member;
    _controller = TextEditingController(text: member?.nickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final viewModel = context.read<EditProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final success = await viewModel.save(_controller.text);
    if (!mounted) return;

    if (success) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('프로필을 수정했어요.')));
      router.pop(); // 마이페이지에는 새 닉네임이 이미 반영되어 있다.
    } else if (viewModel.message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(viewModel.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthViewModel, String?>((a) => a.member?.email);
    final textTheme = Theme.of(context).textTheme;

    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        final saving = viewModel.status == EditProfileStatus.saving;
        return PopScope(
          canPop: !saving,
          child: Scaffold(
            backgroundColor: AppColors.surfaceBase,
            appBar: AppBar(
              backgroundColor: AppColors.surfaceBase,
              centerTitle: true,
              title: Text(
                '프로필 수정',
                style: textTheme.titleLarge?.copyWith(color: AppColors.primary500),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: email,
                    enabled: false, // email은 읽기 전용
                    decoration: const InputDecoration(labelText: '이메일'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    enabled: !saving,
                    maxLength: 12,
                    decoration: InputDecoration(
                      labelText: '닉네임',
                      helperText: '2~12자',
                      errorText: viewModel.nicknameError,
                    ),
                    onSubmitted: (_) {
                      if (!saving) _submit();
                    },
                  ),
                  const Spacer(),
                  SafeArea(
                    top: false,
                    child: MovieLogButton(
                      label: '저장',
                      width: double.infinity,
                      height: 52,
                      isLoading: saving,
                      onPressed: saving ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
