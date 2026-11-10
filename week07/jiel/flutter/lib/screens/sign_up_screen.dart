import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/create_member_request.dart';
import '../theme/app_colors.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/movielog_button.dart';

// 로컬 형식 검사(validator). 서버 중복 여부는 모르며, 중복 확인은 ViewModel이 담당한다.
// 클라이언트 검증은 빠른 안내용이고 서버 검증(400)을 대체하지 않는다.
String? validateNickname(String? value) {
  final nickname = value?.trim() ?? '';
  if (nickname.isEmpty) return '닉네임을 입력해주세요.';
  if (nickname.length < 2 || nickname.length > 12) {
    return '닉네임은 2~12자여야 합니다.';
  }
  return null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return '이메일을 입력해주세요';
  if (!email.contains('@') || !email.contains('.')) return '올바른 이메일 형식이 아닙니다';
  return null;
}

/// v6 회원가입 비밀번호 제약: 8자 이상, 소문자·대문자·숫자·!@#$%^&* 특수문자 각각 1개 이상.
/// 비밀번호는 trim()하지 않으므로 앞뒤 공백도 여기서 명확히 막는다.
String? validatePasswordFormat(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return '비밀번호를 입력해주세요';
  if (password.trim() != password) return '비밀번호 앞뒤에 공백을 넣을 수 없습니다';
  if (password.length < 8) return '비밀번호는 8자 이상이어야 합니다';
  final hasLower = password.contains(RegExp(r'[a-z]'));
  final hasUpper = password.contains(RegExp(r'[A-Z]'));
  final hasDigit = password.contains(RegExp(r'[0-9]'));
  final hasSpecial = password.contains(RegExp(r'[!@#$%^&*]'));
  if (!hasLower || !hasUpper || !hasDigit || !hasSpecial) {
    return '대문자/소문자/숫자/특수문자(!@#\$%^&*)를 각각 포함해야 합니다';
  }
  return null;
}

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

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _autoValidate = true);
      return;
    }
    FocusScope.of(context).unfocus();

    final viewModel = context.read<SignUpViewModel>();
    // 제출 중이면 ViewModel이 무시한다(연속 탭 방지). 버튼도 isLoading으로 잠긴다.
    await viewModel.submit(CreateMemberRequest(
      email: _emailController.text,
      password: _passwordController.text,
      nickname: _nicknameController.text,
    ));
    // 저장 요청과 화면 이동/Snackbar는 서로 다른 비동기 경계. await 뒤에는 mounted를 다시 확인한다.
    if (!mounted) return;

    final createdMemberId = viewModel.createdMemberId;
    if (viewModel.submitStatus == SubmitStatus.success &&
        createdMemberId != null) {
      // 가입 결과의 memberId를 학습용 세션에 보관한다. 이후 평점 요청 path에서 이 값을 읽는다.
      context.read<LearningMemberSession>().setMemberId(createdMemberId);
      // 성공 응답의 result.memberId를 화면에서 바로 확인할 수 있게 Snackbar로 보여준다.
      // ScaffoldMessenger는 MaterialApp 최상단에 있어 화면이 바뀌어도 Snackbar가 유지된다.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('회원가입 완료! 학습용 memberId: $createdMemberId'),
            duration: const Duration(seconds: 4),
          ),
        );
      // go로 스택을 교체해 영화 목록에서 회원가입으로 돌아갈 수 없게 한다.
      context.go('/movies');
      return;
    }

    // 실패: 입력값은 컨트롤러에 그대로 남아 있다(입력 보존).
    final message = viewModel.snackbarMessage;
    if (message != null) {
      viewModel.consumeSnackbarMessage();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();
    // 형식 검사 + 서버 중복 확인(닉네임·이메일 모두 사용 가능)까지 끝나야 가입할 수 있다.
    final canSubmit =
        validateNickname(_nicknameController.text) == null &&
        validateEmail(_emailController.text) == null &&
        validatePasswordFormat(_passwordController.text) == null &&
        _agreedToTerms &&
        viewModel.isAllChecked &&
        !viewModel.isSubmitting;

    // 회원가입 화면에서는 시스템 뒤로 가기를 막는다.
    // (제출 중 이탈 방지도 포함 — 요청이 서버에 도착했는데 화면만 사라지는 상황을 막는다)
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
                    viewModel: viewModel,
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
                    isSubmitting: viewModel.isSubmitting,
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
    required this.viewModel,
    required this.nicknameController,
    required this.emailController,
    required this.emailFocusNode,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.autovalidate,
    required this.onPasswordSubmitted,
  });

  final SignUpViewModel viewModel;
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
          enabled: !viewModel.isSubmitting,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => emailFocusNode.requestFocus(),
          validator: validateNickname,
          onChanged: viewModel.onNicknameChanged,
          serverErrorText: viewModel.nicknameErrorText,
          checkStatus: viewModel.nicknameCheckStatus,
          availableText: '사용할 수 있는 닉네임입니다.',
          // 입력창 옆 보조 버튼: width를 주지 않아(null) 내용 기반 크기를 쓴다.
          trailing: MovieLogButton(
            label: '중복 확인',
            height: 48,
            isLoading: viewModel.nicknameCheckStatus == CheckStatus.checking,
            onPressed: viewModel.canCheckNickname &&
                    validateNickname(nicknameController.text) == null
                ? () => viewModel.checkNickname(nicknameController.text)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        _LabeledTextField(
          label: '이메일',
          controller: emailController,
          focusNode: emailFocusNode,
          autovalidate: autovalidate,
          hintText: '이메일 주소를 입력해주세요',
          enabled: !viewModel.isSubmitting,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
          keyboardType: TextInputType.emailAddress,
          validator: validateEmail,
          onChanged: viewModel.onEmailChanged,
          serverErrorText: viewModel.emailErrorText,
          checkStatus: viewModel.emailCheckStatus,
          availableText: '사용할 수 있는 이메일입니다.',
          trailing: MovieLogButton(
            label: '중복 확인',
            height: 48,
            isLoading: viewModel.emailCheckStatus == CheckStatus.checking,
            onPressed: viewModel.canCheckEmail &&
                    validateEmail(emailController.text) == null
                ? () => viewModel.checkEmail(emailController.text)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        _LabeledTextField(
          label: '비밀번호',
          controller: passwordController,
          focusNode: passwordFocusNode,
          autovalidate: autovalidate,
          hintText: '비밀번호를 입력해주세요',
          obscureText: true,
          enabled: !viewModel.isSubmitting,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: onPasswordSubmitted,
          // 로컬 validator와 서버 400 응답이 동시에 작동한다.
          // 로컬 validator가 통과한 뒤에도 서버가 거부한 값이면 errorText로 계속 에러로 보인다.
          validator: validatePasswordFormat,
          onChanged: (_) => viewModel.onPasswordChanged(),
          serverErrorText: viewModel.passwordErrorText,
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
    required this.isSubmitting,
    required this.onSubmit,
    required this.onLoginTap,
  });

  final bool agreedToTerms;
  final ValueChanged<bool?> onAgreedToTermsChanged;
  final bool canSubmit;
  final bool isSubmitting;
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
          onChanged: isSubmitting ? null : onAgreedToTermsChanged,
          title: Text(
            '필수 약관에 동의합니다',
            style: textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
          ),
        ),
        const SizedBox(height: 24),
        // Form 하단 버튼: 전체 너비. 제출 중에는 회색 + 인디케이터로 바뀌어 중복 탭을 막는다.
        MovieLogButton(
          label: '가입하기',
          width: double.infinity,
          height: 56,
          isLoading: isSubmitting,
          onPressed: canSubmit ? onSubmit : null,
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
    this.enabled = true,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autovalidate = false,
    this.keyboardType,
    this.onChanged,
    this.serverErrorText,
    this.checkStatus,
    this.availableText,
    this.trailing,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final bool obscureText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String> validator;
  // 제출을 한 번 시도한 뒤부터 true로 바뀌어, 타이핑할 때마다 실시간으로
  // 에러 스타일(배경/테두리/문구)을 반영한다. 이 값과 무관하게 Form의
  // validator 자체는 항상 등록돼 있어서, 제출 버튼을 눌렀을 때의
  // Form.validate() 호출은 정상적으로 동작한다.
  final bool autovalidate;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  /// ViewModel이 내려준 서버 중복 확인 에러 문구. 로컬 validator가 통과해도
  /// 이 값이 있으면 입력창은 에러 상태로 보인다.
  final String? serverErrorText;

  /// 서버 중복 확인이 필요한 필드면 그 상태. null이면 로컬 검사만 하는 필드.
  final CheckStatus? checkStatus;

  /// 서버가 사용 가능하다고 응답했을 때 입력창 아래에 보여줄 안내 문구.
  final String? availableText;

  /// 입력창 오른쪽(바깥)에 나란히 둘 위젯. 예: 중복 확인 버튼
  final Widget? trailing;

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
    final hasLocalError = isTouched && validator(controller.text) != null;
    final hasError = hasLocalError || serverErrorText != null;
    final isAvailable = checkStatus == CheckStatus.available;
    // 중복 확인이 필요한 필드는 서버가 "사용 가능"이라고 답했을 때만 체크 표시를 한다.
    final isValid = isTouched &&
        !hasError &&
        (checkStatus == null || isAvailable);
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
        _withTrailing(TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          validator: validator,
          // onUserInteraction은 "값이 바뀐 뒤"에만 검증하므로, 아직 아무것도
          // 안 건드린 빈칸 필드가 처음부터 빨갛게 뜨는 일은 없다.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: hasError ? errorBackground : AppColors.surfaceLow,
            hintText: hintText,
            // 로컬 validator 에러가 없을 때 이 값이 표시된다(서버 중복/통신 실패 문구).
            errorText: serverErrorText,
            errorMaxLines: 2,
            helperText: isAvailable ? availableText : null,
            helperStyle: textTheme.labelMedium?.copyWith(
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.primary500,
            ),
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
        )),
      ],
    );
  }

  /// trailing이 있으면 입력창과 trailing을 Row의 별도 형제로 두고 8px 간격을 준다.
  /// 체크 아이콘은 입력창 내부(suffixIcon)에만 있으므로 버튼과 겹치지 않는다.
  Widget _withTrailing(Widget field) {
    final trailingWidget = trailing;
    if (trailingWidget == null) return field;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field),
        const SizedBox(width: 8),
        trailingWidget,
      ],
    );
  }
}
