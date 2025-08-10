import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/utils/extensions/validation_extension.dart';

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({
    super.key,
    required this.focusNode,
    required this.password,
    required this.onPasswordChanged,
    required this.onPasswordConfirmChanged,
    required this.isPasswordVisible,
    required this.isPasswordConfirmVisible,
    required this.onPasswordVisible,
    required this.onPasswordConfirmVisible,
  });

  final FocusNode focusNode;
  final String password;
  final Function(String) onPasswordChanged;
  final Function(String) onPasswordConfirmChanged;
  final bool isPasswordVisible;
  final bool isPasswordConfirmVisible;
  final Function(bool) onPasswordVisible;
  final Function(bool) onPasswordConfirmVisible;

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const AppText(text: '비밀번호', fontSize: 18),
            const SizedBox(height: 8),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildPasswordConfirmField(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  ///
  /// 비밀번호 입력 필드
  ///
  Widget _buildPasswordField() {
    return AppTextField(
      onTextChanged: widget.onPasswordChanged,
      focusNode: widget.focusNode,
      placeholderText: '비밀번호를 입력하세요 (6자 이상)',
      keyboardType: TextInputType.visiblePassword,
      obscureText: !widget.isPasswordVisible,
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlignVertical: TextAlignVertical.center,
      suffixIcon: GestureDetector(
        onTap: () {
          // 비밀번호 보여주기 토글
          widget.onPasswordVisible(!widget.isPasswordVisible);
        },
        child: Icon(
          widget.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: AppColors.colora1a4a6,
          size: 20,
        ),
      ),
      validator: (password) => password?.validatePassword(),
    );
  }

  ///
  /// 비밀번호 입력 필드
  ///
  Widget _buildPasswordConfirmField() {
    return AppTextField(
      onTextChanged: widget.onPasswordConfirmChanged,
      placeholderText: '비밀번호 확인',
      keyboardType: TextInputType.visiblePassword,
      obscureText: !widget.isPasswordConfirmVisible,
      textInputAction: TextInputAction.done,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlignVertical: TextAlignVertical.center,
      suffixIcon: GestureDetector(
        onTap: () {
          // 비밀번호 보여주기 토글
          widget.onPasswordConfirmVisible(!widget.isPasswordConfirmVisible);
        },
        child: Icon(
          widget.isPasswordConfirmVisible
              ? Icons.visibility_off
              : Icons.visibility,
          color: AppColors.colora1a4a6,
          size: 20,
        ),
      ),
      validator: (passwordConfirm) =>
          passwordConfirm?.validatePasswordConfirm(widget.password),
    );
  }
}
