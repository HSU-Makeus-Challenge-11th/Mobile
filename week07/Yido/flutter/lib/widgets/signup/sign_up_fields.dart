import 'package:flutter/material.dart';
import 'package:movielog/sign_up_validators.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:provider/provider.dart';

class SignUpFields extends StatefulWidget {
  const SignUpFields({
    super.key,
    required this.nicknameController,
    required this.emailController,
    required this.passwordController,
    required this.nicknameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.onChanged,
  });

  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode nicknameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final VoidCallback onChanged;

  @override
  State<SignUpFields> createState() => _SignUpFieldsState();
}

class _SignUpFieldsState extends State<SignUpFields> {
  final Set<String> _touched = {};

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();
    final nicknameText = widget.nicknameController.text;
    final emailText = widget.emailController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(
          const Key('nicknameField'),
          'nickname',
          '닉네임',
          '닉네임을 입력해주세요',
          widget.nicknameController,
          widget.nicknameFocusNode,
          SignUpValidators.nickname,
          TextInputAction.next,
          (_) => widget.emailFocusNode.requestFocus(),
          check: _FieldCheck(
            buttonKey: const Key('nicknameCheckButton'),
            status: viewModel.nicknameCheckStatus,
            errorText: viewModel.nicknameErrorText,
            checkingText: '닉네임 사용 가능 여부를 확인 중입니다.',
            availableText: '사용 가능한 닉네임입니다.',
            onChanged: viewModel.onNicknameChanged,
            onCheck:
                viewModel.canCheckNickname &&
                    SignUpValidators.nickname(nicknameText) == null
                ? () => viewModel.checkNickname(nicknameText)
                : null,
          ),
        ),
        SizedBox(
          height: _gapAfter(
            'nickname',
            widget.nicknameController,
            SignUpValidators.nickname,
            viewModel.nicknameCheckStatus,
            viewModel.nicknameErrorText,
          ),
        ),
        _field(
          const Key('emailField'),
          'email',
          '이메일',
          '이메일 주소를 입력해주세요',
          widget.emailController,
          widget.emailFocusNode,
          SignUpValidators.email,
          TextInputAction.next,
          (_) => widget.passwordFocusNode.requestFocus(),
          keyboardType: TextInputType.emailAddress,
          check: _FieldCheck(
            buttonKey: const Key('emailCheckButton'),
            status: viewModel.emailCheckStatus,
            errorText: viewModel.emailErrorText,
            checkingText: '이메일 사용 가능 여부를 확인 중입니다.',
            availableText: '사용 가능한 이메일입니다.',
            onChanged: viewModel.onEmailChanged,
            onCheck:
                viewModel.canCheckEmail &&
                    SignUpValidators.email(emailText) == null
                ? () => viewModel.checkEmail(emailText)
                : null,
          ),
        ),
        SizedBox(
          height: _gapAfter(
            'email',
            widget.emailController,
            SignUpValidators.email,
            viewModel.emailCheckStatus,
            viewModel.emailErrorText,
          ),
        ),
        _field(
          const Key('passwordField'),
          'password',
          '비밀번호',
          '비밀번호를 입력해주세요',
          widget.passwordController,
          widget.passwordFocusNode,
          SignUpValidators.password,
          TextInputAction.done,
          (_) => widget.passwordFocusNode.unfocus(),
          obscureText: true,
        ),
      ],
    );
  }

  /// 안내 문구 자리까지 합쳐 다음 라벨 위치를 고정한다 (문구 6 + 16, 아래 여백 9)
  double _gapAfter(
    String name,
    TextEditingController controller,
    FormFieldValidator<String> validator,
    CheckStatus status,
    String? errorText,
  ) {
    final hasMessage =
        status == CheckStatus.checking ||
        status == CheckStatus.available ||
        errorText != null ||
        (_touched.contains(name) && validator(controller.text) != null);
    return hasMessage ? 9 : 31;
  }

  Widget _field(
    Key key,
    String name,
    String label,
    String hint,
    TextEditingController controller,
    FocusNode node,
    FormFieldValidator<String> validator,
    TextInputAction action,
    ValueChanged<String> submitted, {
    TextInputType? keyboardType,
    bool obscureText = false,
    _FieldCheck? check,
  }) {
    final error = _touched.contains(name) ? validator(controller.text) : null;
    final invalid = error != null || check?.errorText != null;
    // 체크 표시는 서버가 사용 가능하다고 답한 입력란에만 보여 준다
    final valid = check?.status == CheckStatus.available;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: width),
        );

    final input = TextFormField(
      key: key,
      controller: controller,
      focusNode: node,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: action,
      onFieldSubmitted: submitted,
      onChanged: (value) {
        setState(() => _touched.add(name));
        check?.onChanged(value);
        widget.onChanged();
      },
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        height: 19 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.inputText,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14,
          height: 19 / 14,
          fontWeight: FontWeight.w400,
          color: AppColors.inputText,
        ),
        // 서버 중복 확인 결과. 형식 오류가 있으면 validator 문구가 먼저 보인다
        errorText: check?.errorText,
        errorMaxLines: 2,
        errorStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w500,
          color: AppColors.error,
        ),
        filled: true,
        fillColor: invalid ? const Color(0xFFFFDAD6) : AppColors.surfaceBright,
        // 안내 문구를 입력란 왼쪽 끝에 맞추려고 안쪽 여백은 prefixIcon으로 둔다
        contentPadding: const EdgeInsets.fromLTRB(0, 12.5, 16, 12.5),
        prefixIcon: const SizedBox(width: 16),
        prefixIconConstraints: const BoxConstraints.tightFor(
          width: 16,
          height: 44,
        ),
        border: border(AppColors.cardBorder),
        enabledBorder: border(invalid ? AppColors.error : AppColors.cardBorder),
        focusedBorder: border(
          invalid ? AppColors.error : AppColors.primary500,
          2,
        ),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 2),
        suffixIconConstraints: const BoxConstraints.tightFor(
          width: 32,
          height: 44,
        ),
        suffixIcon: valid
            ? const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Center(child: _CheckMark()),
              )
            : invalid
            ? const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.error_outline,
                  size: 20,
                  color: AppColors.error,
                  semanticLabel: '입력 오류',
                ),
              )
            : null,
      ),
    );

    final status = check?.status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            height: 19 / 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 7),
        if (check == null)
          input
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: input),
              const SizedBox(width: 10),
              MovieLogButton(
                key: check.buttonKey,
                label: '중복 확인',
                isLoading: status == CheckStatus.checking,
                onPressed: check.onCheck,
              ),
            ],
          ),
        if (status == CheckStatus.checking)
          _statusText(check!.checkingText, AppColors.info)
        else if (status == CheckStatus.available)
          _statusText(check!.availableText, AppColors.success),
      ],
    );
  }

  Widget _statusText(String text, Color color) => Padding(
    padding: const EdgeInsets.only(left: 1, top: 6),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );
}

/// 입력란 하나의 중복 확인 상태. 닉네임과 이메일 결과를 섞지 않도록 따로 전달한다
class _FieldCheck {
  const _FieldCheck({
    required this.buttonKey,
    required this.status,
    required this.errorText,
    required this.checkingText,
    required this.availableText,
    required this.onChanged,
    required this.onCheck,
  });

  final Key buttonKey;
  final CheckStatus status;
  final String? errorText;
  final String checkingText;
  final String availableText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCheck;
}

/// W6-01의 입력칸 체크 표시: 20 크기 원에 2px 흰 선
class _CheckMark extends StatelessWidget {
  const _CheckMark();

  @override
  Widget build(BuildContext context) => Semantics(
    label: '입력 완료',
    child: const CustomPaint(size: Size.square(20), painter: _CheckPainter()),
  );
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2,
      Paint()..color = AppColors.primary500,
    );
    canvas.drawPath(
      Path()
        ..moveTo(5, 10)
        ..lineTo(9, 14)
        ..lineTo(16, 6),
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => false;
}
