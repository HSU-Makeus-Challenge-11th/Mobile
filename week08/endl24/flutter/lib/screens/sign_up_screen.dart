import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:movielog/view_models/submit_status.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/login_prompt.dart';
import 'package:movielog/widgets/movie_log_text_form_field.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/widgets/sign_up_header.dart';
import 'package:movielog/widgets/terms_agreement.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _agreedToTerms = false;
  final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final _passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '회원가입',
        centerTitle: true,
        onBack: () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 560 : double.infinity,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SignUpHeader(),
                        const SizedBox(height: 40),
                        Consumer<SignUpViewModel>(
                          builder: (context, viewModel, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MovieLogTextFormField(
                                  label: '닉네임',
                                  hintText: '닉네임을 입력해주세요',
                                  controller: _nicknameController,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    final nickname = value?.trim() ?? '';
                                    if (nickname.isEmpty) {
                                      return '닉네임을 입력해주세요.';
                                    }
                                    if (nickname.length < 2) {
                                      return '닉네임은 2자 이상이어야 합니다.';
                                    }
                                    return null;
                                  },
                                  errorText: viewModel.nicknameErrorText,
                                  onChanged: (value) {
                                    setState(() {});
                                    viewModel.onNicknameChanged(value);
                                  },
                                  onFieldSubmitted: (_) =>
                                      _emailFocusNode.requestFocus(),
                                  trailing: MovieLogButton(
                                    label: '중복 확인',
                                    height: 52, // 입력창 높이에 맞춥니다.
                                    isLoading:
                                        viewModel.nicknameCheckStatus ==
                                        CheckStatus.checking,
                                    onPressed:
                                        viewModel.canCheckNickname &&
                                            _isNicknameFormatValid
                                        ? () => viewModel.checkNickname(
                                            _nicknameController.text,
                                          )
                                        : null,
                                  ),
                                ),
                                if (viewModel.nicknameCheckStatus ==
                                    CheckStatus.available) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '사용할 수 있는 닉네임입니다.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.violet,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                MovieLogTextFormField(
                                  label: '이메일',
                                  hintText: '이메일을 입력해주세요',
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    final email = value?.trim() ?? '';
                                    if (email.isEmpty) return '이메일을 입력해주세요.';
                                    if (!_emailRegExp.hasMatch(email)) {
                                      return '올바른 이메일 형식이 아닙니다.';
                                    }
                                    return null;
                                  },
                                  errorText: viewModel.emailErrorText,
                                  onChanged: (value) {
                                    setState(() {});
                                    viewModel.onEmailChanged(value);
                                  },
                                  onFieldSubmitted: (_) =>
                                      _passwordFocusNode.requestFocus(),
                                  trailing: MovieLogButton(
                                    label: '중복 확인',
                                    height: 52, // 입력창 높이에 맞춥니다.
                                    isLoading:
                                        viewModel.emailCheckStatus ==
                                        CheckStatus.checking,
                                    onPressed:
                                        viewModel.canCheckEmail &&
                                            _isEmailFormatValid
                                        ? () => viewModel.checkEmail(
                                            _emailController.text,
                                          )
                                        : null,
                                  ),
                                ),
                                if (viewModel.emailCheckStatus ==
                                    CheckStatus.available) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '사용할 수 있는 이메일입니다.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.violet,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Consumer<SignUpViewModel>(
                          builder: (context, viewModel, child) {
                            return MovieLogTextFormField(
                              label: '비밀번호',
                              hintText: '비밀번호를 입력해주세요',
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              textInputAction: TextInputAction.done,
                              obscureText: true,
                              validator: (value) {
                                final password = value ?? '';
                                if (password.isEmpty) {
                                  return '비밀번호를 입력해주세요.';
                                }
                                if (!_passwordRegExp.hasMatch(password)) {
                                  return '영문과 숫자를 포함해 8자 이상 입력해주세요.';
                                }
                                return null;
                              },
                              // 로컬 검사를 통과해도 서버가 거부하면 계속 에러로 보여줍니다.
                              errorText: viewModel.passwordErrorText,
                              onChanged: (_) {
                                setState(() {});
                                viewModel.onPasswordChanged();
                              },
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                            );
                          },
                        ),
                        const SizedBox(height: 48),
                        TermsAgreement(
                          value: _agreedToTerms,
                          onChanged: (value) =>
                              setState(() => _agreedToTerms = value),
                        ),
                        const SizedBox(height: 16),
                        Consumer<SignUpViewModel>(
                          builder: (context, viewModel, child) {
                            final checked =
                                viewModel.nicknameCheckStatus ==
                                    CheckStatus.available &&
                                viewModel.emailCheckStatus ==
                                    CheckStatus.available;
                            final submitting =
                                viewModel.submitStatus ==
                                SubmitStatus.submitting;
                            return MovieLogButton(
                              label: '가입하기',
                              width: double.infinity,
                              isLoading: submitting,
                              onPressed: _canSubmit && checked && !submitting
                                  ? _submit
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        const LoginPrompt(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool get _isNicknameFormatValid =>
      _nicknameController.text.trim().length >= 2;
  bool get _isEmailFormatValid =>
      _emailRegExp.hasMatch(_emailController.text.trim());

  bool get _canSubmit =>
      _nicknameController.text.trim().length >= 2 &&
      _emailRegExp.hasMatch(_emailController.text.trim()) &&
      _passwordRegExp.hasMatch(_passwordController.text) &&
      _agreedToTerms;
  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    FocusScope.of(context).unfocus();

    final viewModel = context.read<SignUpViewModel>();
    await viewModel.submit(
      CreateMemberRequest(
        email: _emailController.text,
        password: _passwordController.text,
        nickname: _nicknameController.text,
      ),
    );
    if (!mounted) return; // 요청 중 화면을 떠났다면 결과를 반영하지 않습니다.

    if (viewModel.submitStatus == SubmitStatus.success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료됐어요. 로그인해 주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      context.pop(); // 회원가입은 로그인 화면에서 push로 열립니다.
      return;
    }
    final message = viewModel.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
