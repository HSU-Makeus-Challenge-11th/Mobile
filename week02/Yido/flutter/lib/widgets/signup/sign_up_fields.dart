import 'package:flutter/material.dart';
import 'package:movielog/sign_up_validators.dart';

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
    required this.onErrorStateChanged,
  });

  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode nicknameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final VoidCallback onChanged;
  final ValueChanged<bool> onErrorStateChanged;

  @override
  State<SignUpFields> createState() => _SignUpFieldsState();
}

class _SignUpFieldsState extends State<SignUpFields> {
  final Set<String> _touched = {};

  @override
  Widget build(BuildContext context) => Column(
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
      ),
      const SizedBox(height: 16),
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
      ),
      const SizedBox(height: 16),
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

  bool get _hasErrors =>
      _touched.contains('nickname') &&
          SignUpValidators.nickname(widget.nicknameController.text) != null ||
      _touched.contains('email') &&
          SignUpValidators.email(widget.emailController.text) != null ||
      _touched.contains('password') &&
          SignUpValidators.password(widget.passwordController.text) != null;

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
  }) {
    final valid =
        controller.text.isNotEmpty && validator(controller.text) == null;
    final error = _touched.contains(name) ? validator(controller.text) : null;
    final invalid = error != null;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D1B20),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: invalid ? 66 : 42,
          child: TextFormField(
            key: key,
            controller: controller,
            focusNode: node,
            validator: validator,
            errorBuilder: (context, errorText) => Transform.translate(
              offset: const Offset(-16, 0),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  errorText,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFB3261E),
                  ),
                ),
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: keyboardType,
            obscureText: obscureText,
            textInputAction: action,
            onFieldSubmitted: submitted,
            onChanged: (_) {
              setState(() => _touched.add(name));
              widget.onChanged();
              widget.onErrorStateChanged(_hasErrors);
            },
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              height: 24 / 16,
              fontWeight: valid && name == 'nickname'
                  ? FontWeight.w500
                  : FontWeight.w400,
              color: const Color(0xFF1D1B20),
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                height: 22 / 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7A7582),
              ),
              filled: true,
              fillColor: invalid
                  ? const Color(0xFFFFDAD6)
                  : const Color(0xFFF5F3F0),
              contentPadding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
              border: border(const Color(0xFFCBC4D2)),
              enabledBorder: border(
                invalid ? const Color(0xFFB3261E) : const Color(0xFFCBC4D2),
              ),
              focusedBorder: border(
                invalid ? const Color(0xFFB3261E) : const Color(0xFF6750A4),
                2,
              ),
              errorBorder: border(const Color(0xFFB3261E)),
              focusedErrorBorder: border(const Color(0xFFB3261E), 2),
              suffixIconConstraints: const BoxConstraints.tightFor(
                width: 36,
                height: 42,
              ),
              suffixIcon: valid || invalid
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        valid ? Icons.check_circle : Icons.error_outline,
                        size: 20,
                        color: valid
                            ? const Color(0xFF6750A4)
                            : const Color(0xFFB3261E),
                        semanticLabel: valid ? '입력 완료' : '입력 오류',
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
