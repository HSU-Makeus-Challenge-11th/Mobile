import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _agreedToTerms = false;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _autoValidate = true);
      return;
    }
    FocusScope.of(context).unfocus();
    // 검증 완료 → 홈으로 이동. go로 스택을 교체해 홈에서 회원가입으로 돌아갈 수 없게 한다.
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _nicknameController.text.trim().length >= 2 &&
        _emailController.text.contains('@') &&
        _passwordController.text.length >= 8 &&
        _agreedToTerms;

    // 회원가입 화면에서는 시스템 뒤로 가기를 막는다.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.surfaceBase,
        appBar: const _SignUpAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SignUpFormSection(
                    nicknameController: _nicknameController,
                    emailController: _emailController,
                    emailFocusNode: _emailFocusNode,
                    passwordController: _passwordController,
                    passwordFocusNode: _passwordFocusNode,
                    autovalidate: _autoValidate,
                    onPasswordSubmitted: (_) => canSubmit ? _submit() : null,
                  ),
                  // 폼과 약관 동의/버튼 영역 사이 여백을 넓혀서 아래쪽으로 내려 보이게 함
                  const SizedBox(height: 64),
                  _SignUpFooter(
                    agreedToTerms: _agreedToTerms,
                    onAgreedToTermsChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                    canSubmit: canSubmit,
                    onSubmit: _submit,
                    onLoginTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}

/// 상단바: 가운데 정렬된 "회원가입" 타이틀.
/// 뒤로 가기가 동작하면 안 되는 화면이라 뒤로가기 버튼은 두지 않는다.
/// 다른 화면이 쓰는 공용 [TopAppBar]와 달리 이 화면 전용으로 분리했다
/// (디자인상 이 화면은 공용 내비게이션이 아닌 단일 트랜잭션 화면이라서).
class _SignUpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SignUpAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: AppColors.surfaceBase,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        '회원가입',
        style: textTheme.titleLarge?.copyWith(color: AppColors.primary500),
      ),
    );
  }
}

/// 환영 문구 + 닉네임/이메일/비밀번호 입력 폼. 디자인 스펙의
/// "Main - Form Section"에 해당하는 묶음이다.
class _SignUpFormSection extends StatelessWidget {
  const _SignUpFormSection({
    required this.nicknameController,
    required this.emailController,
    required this.emailFocusNode,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.autovalidate,
    required this.onPasswordSubmitted,
  });

  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final FocusNode emailFocusNode;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final bool autovalidate;
  final ValueChanged<String> onPasswordSubmitted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        // CSS: 안내 문구 wrapper의 자체 padding-bottom(16) + 폼 영역과의 gap(32)
        const SizedBox(height: 48),
        _LabeledTextField(
          label: '닉네임',
          controller: nicknameController,
          autovalidate: autovalidate,
          hintText: '닉네임을 입력해주세요',
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => emailFocusNode.requestFocus(),
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
        ),
        const SizedBox(height: 16),
        _LabeledTextField(
          label: '이메일',
          controller: emailController,
          focusNode: emailFocusNode,
          autovalidate: autovalidate,
          hintText: '이메일 주소를 입력해주세요',
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '이메일을 입력해주세요';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return '올바른 이메일 형식이 아닙니다';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _LabeledTextField(
          label: '비밀번호',
          controller: passwordController,
          focusNode: passwordFocusNode,
          autovalidate: autovalidate,
          hintText: '비밀번호를 입력해주세요',
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: onPasswordSubmitted,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호를 입력해주세요';
            }
            if (value.length < 8) {
              return '비밀번호는 8자 이상이어야 합니다';
            }
            return null;
          },
        ),
      ],
    );
  }
}

/// 약관 동의 체크박스 + 가입하기 버튼 + 로그인 링크. 디자인 스펙에서
/// 폼과 분리된 하단 "Margin"(footer) 블록에 해당한다.
class _SignUpFooter extends StatelessWidget {
  const _SignUpFooter({
    required this.agreedToTerms,
    required this.onAgreedToTermsChanged,
    required this.canSubmit,
    required this.onSubmit,
    required this.onLoginTap,
  });

  final bool agreedToTerms;
  final ValueChanged<bool?> onAgreedToTermsChanged;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: agreedToTerms,
          activeColor: AppColors.primary500,
          checkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: const BorderSide(color: AppColors.primary500),
          onChanged: onAgreedToTermsChanged,
          title: Text(
            '필수 약관에 동의합니다',
            style: textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: canSubmit ? onSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary500,
            disabledBackgroundColor: AppColors.secondary300,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            '가입하기',
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '이미 계정이 있나요? ',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            GestureDetector(
              onTap: onLoginTap,
              child: Text(
                '로그인',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 라벨 + 입력창 한 쌍. 회원가입 폼의 닉네임/이메일/비밀번호 필드가
/// 모두 같은 스타일(배경 #F5F3F0, 테두리 #CBC4D2, radius 8)을 쓰기 때문에
/// 중복을 줄이려고 분리했다.
class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.validator,
    this.focusNode,
    this.obscureText = false,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autovalidate = false,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String> validator;
  // 제출을 한 번 시도한 뒤부터 true로 바뀌어, 타이핑할 때마다 실시간으로
  // 에러 스타일(배경/테두리/문구)을 반영한다. 이 값과 무관하게 Form의
  // validator 자체는 항상 등록돼 있어서, 제출 버튼을 눌렀을 때의
  // Form.validate() 호출은 정상적으로 동작한다.
  final bool autovalidate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;
    // 실제 FormFieldState의 에러와 같은 값(같은 validator, 같은 입력값으로
    // 계산)이라 항상 일치한다. 입력창 배경색까지 바꾸려면 이 값이 필요한데,
    // TextFormField는 자신의 에러 상태를 부모에게 알려주는 콜백이 없다.
    // - autovalidate: 제출을 한 번 시도한 뒤라 아직 안 건드린(빈칸) 필드까지 포함해서 보여준다.
    // - controller.text.isNotEmpty: 제출 전이라도, 뭔가 입력하자마자 바로 피드백을 준다.
    final isTouched = autovalidate || controller.text.isNotEmpty;
    final hasError = isTouched && validator(controller.text) != null;
    final isValid = isTouched && !hasError;
    // 디자인이 지정한 에러 배경색(#FFDAD6)은 Material 3 표준 errorContainer
    // 값과 같은데, 현재 앱 테마의 errorContainer(#F9DEDC)는 이와 다르다.
    // 이 화면 스펙에 정확히 맞추기 위해 값을 직접 사용했다.
    const errorBackground = Color(0xFFFFDAD6);
    final borderColor = hasError ? errorColor : const Color(0xFFCBC4D2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          // onUserInteraction은 "값이 바뀐 뒤"에만 검증하므로, 아직 아무것도
          // 안 건드린 빈칸 필드가 처음부터 빨갛게 뜨는 일은 없다.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: hasError ? errorBackground : AppColors.surfaceLow,
            hintText: hintText,
            hintStyle: textTheme.titleMedium?.copyWith(
              height: 22 / 16,
              color: AppColors.neutral800,
            ),
            errorStyle: textTheme.labelMedium?.copyWith(
              fontSize: 12,
              height: 16 / 12,
              color: errorColor,
            ),
            suffixIcon: hasError
                ? Icon(Icons.error_outline, color: errorColor, size: 20)
                : isValid
                ? const Icon(
                    Icons.check_circle,
                    color: AppColors.primary500,
                    size: 20,
                  )
                : null,
            contentPadding: const EdgeInsets.fromLTRB(16, 9, 16, 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? errorColor : AppColors.primary500,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: errorColor),
            ),
          ),
        ),
      ],
    );
  }
}
