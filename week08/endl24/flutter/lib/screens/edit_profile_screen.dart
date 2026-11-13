import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/edit_profile_view_model.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:provider/provider.dart';

/// 이메일은 읽기 전용, 닉네임만 수정하는 화면입니다.
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
        ..showSnackBar(
          const SnackBar(
            content: Text('프로필을 수정했어요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      router.pop(); // 마이페이지에는 새 닉네임이 이미 반영되어 있습니다.
    } else if (viewModel.message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(viewModel.message!),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  /// 바뀐 내용이 있을 때 뒤로가기를 누르면 확인 Dialog를 띄웁니다.
  /// "나가기"를 고르면 마이페이지로, "계속 수정"이면 이 화면에 머무릅니다.
  Future<void> _confirmDiscard() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (_) => const _DiscardChangesDialog(),
    );
    if (leave == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthViewModel, String?>(
      (auth) => auth.member?.email,
    );
    final savedNickname = context.select<AuthViewModel, String?>(
      (auth) => auth.member?.nickname,
    );
    // 입력값이 지금 저장된 닉네임과 다르면 "변경 내용이 있다"고 봅니다.
    final hasChanges = _controller.text.trim() != (savedNickname ?? '');

    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        final saving = viewModel.status == EditProfileStatus.saving;
        return PopScope(
          // 저장 중이거나 바뀐 내용이 있으면 바로 닫지 않습니다.
          canPop: !saving && !hasChanges,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop || saving) return; // 이미 닫혔거나 저장 중이면 아무것도 하지 않음
            _confirmDiscard(); // 바뀐 내용이 있어 막힌 경우에만 확인합니다.
          },
          child: Scaffold(
            appBar: CommonAppBar(
              title: '프로필 수정',
              centerTitle: true,
              // 시스템 뒤로가기와 같은 규칙(PopScope)을 따르도록 maybePop을 씁니다.
              onBack: () => Navigator.maybePop(context),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FieldLabel('이메일 (변경할 수 없습니다)'),
                    TextFormField(
                      initialValue: email,
                      enabled: false, // email은 읽기 전용입니다.
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grayDark,
                      ),
                      decoration: _decoration(),
                    ),
                    const SizedBox(height: 24),
                    const _FieldLabel('닉네임'),
                    TextField(
                      controller: _controller,
                      enabled: !saving,
                      maxLength: 12, // 오른쪽 아래에 '4/12' 카운터가 생깁니다.
                      textInputAction: TextInputAction.done,
                      onChanged: (_) {
                        setState(() {}); // 변경 여부(hasChanges)를 다시 계산합니다.
                        viewModel.onNicknameChanged();
                      },
                      onSubmitted: (_) {
                        if (!saving) _submit();
                      },
                      decoration: _decoration(
                        errorText: viewModel.nicknameError,
                      ),
                    ),
                    const Spacer(),
                    MovieLogButton(
                      label: '저장',
                      width: double.infinity,
                      height: 52,
                      isLoading: saving,
                      onPressed: saving ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _decoration({String? errorText}) {
    return InputDecoration(
      errorText: errorText,
      errorMaxLines: 2,
      filled: true,
      fillColor: AppColors.grayLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorStyle: const TextStyle(fontSize: 12, color: AppColors.red),
      enabledBorder: _border(AppColors.grayLine),
      disabledBorder: _border(AppColors.grayLine),
      focusedBorder: _border(AppColors.violet, width: 1.5),
      errorBorder: _border(AppColors.red),
      focusedErrorBorder: _border(AppColors.red, width: 1.5),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 변경 내용이 있을 때 뒤로가기 확인 Dialog입니다. true면 나가기, false면 계속 수정입니다.
class _DiscardChangesDialog extends StatelessWidget {
  const _DiscardChangesDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('변경 내용을 버릴까요?', textAlign: TextAlign.center),
      content: Text(
        '저장하지 않은 내용은 사라집니다.',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grayDark),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violetLight,
                  foregroundColor: AppColors.violet,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('계속 수정'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MovieLogButton(
                label: '나가기',
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
