import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/edit_profile_view_model.dart';
import '../../widgets/common_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const routeName = '/my/profile/edit';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _nickname = TextEditingController(
    text: context.read<AuthViewModel>().member?.nickname ?? '',
  );
  late final _viewModel = EditProfileViewModel(context.read<AuthViewModel>())
    ..addListener(_changed);

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_changed)
      ..dispose();
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await _viewModel.save(_nickname.text);
    if (!mounted || !saved) {
      if (mounted && _viewModel.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_viewModel.message!)));
      }
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(const SnackBar(content: Text('닉네임을 수정했습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthViewModel>().member;
    return PopScope(
      canPop: !_viewModel.isSaving,
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        appBar: CommonAppBar(title: '프로필 수정', onBack: () => context.pop()),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('profile-email-field'),
                  initialValue: member?.email ?? '',
                  readOnly: true,
                  decoration: const InputDecoration(labelText: '이메일'),
                ),
                const SizedBox(height: 20),
                TextField(
                  key: const Key('profile-nickname-field'),
                  controller: _nickname,
                  enabled: !_viewModel.isSaving,
                  maxLength: 12,
                  onChanged: (_) => _viewModel.clearFieldError(),
                  decoration: InputDecoration(
                    labelText: '닉네임',
                    errorText: _viewModel.fieldError,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  key: const Key('profile-save-button'),
                  onPressed: _viewModel.isSaving ? null : _save,
                  child: _viewModel.isSaving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('저장'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
