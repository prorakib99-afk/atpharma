import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/routes/app_routes.dart';

class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key, this.onResetPassword});

  static const String routeName = '/reset-password';

  final Future<void> Function(String password)? onResetPassword;

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      await widget.onResetPassword?.call(_passwordController.text);
      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.resetPasswordSuccess);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 720;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  _ResetLayout.pagePadding(constraints.maxWidth),
                  compact ? 8 : 22,
                  _ResetLayout.pagePadding(constraints.maxWidth),
                  24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (compact ? 32 : 46),
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/reset_password_illustration.png',
                            width: compact ? 232 : 294,
                            height: compact ? 232 : 294,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: compact ? 16 : 30),
                          const Text(
                            'Reset Password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              height: 28 / 24,
                              fontWeight: FontWeight.w600,
                              color: _ResetColors.title,
                            ),
                          ),
                          SizedBox(height: compact ? 24 : 32),
                          _PasswordField(
                            label: 'New Password',
                            hint: 'New Password',
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            onVisibilityTap: () =>
                                setState(() => _hidePassword = !_hidePassword),
                            validator: (value) {
                              if ((value ?? '').length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _PasswordField(
                            label: 'Confirm New Password',
                            hint: 'Confirm Password',
                            controller: _confirmController,
                            obscureText: _hideConfirmation,
                            onVisibilityTap: () => setState(
                              () => _hideConfirmation = !_hideConfirmation,
                            ),
                            onSubmitted: (_) => _submit(),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          _ResetButton(
                            loading: _isSubmitting,
                            onPressed: _submit,
                          ),
                          const Spacer(),
                          const SizedBox(height: 36),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).popUntil(
                              (route) => route.settings.name == AppRoutes.login,
                            ),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 15,
                            ),
                            label: const Text('Back to Sign In'),
                            style: TextButton.styleFrom(
                              foregroundColor: _ResetColors.primary,
                              textStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscureText,
    required this.onVisibilityTap,
    required this.validator,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onVisibilityTap;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 24 / 14,
            fontWeight: FontWeight.w500,
            color: _ResetColors.label,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: onSubmitted == null
              ? TextInputAction.next
              : TextInputAction.done,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: _ResetColors.title,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: _ResetColors.muted,
            ),
            prefixIcon: Center(
              child: SvgPicture.asset(
                'assets/icons/lock.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  _ResetColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              maxWidth: 48,
              minHeight: 48,
            ),
            suffixIcon: IconButton(
              onPressed: onVisibilityTap,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: _ResetColors.tertiary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: _border(_ResetColors.border),
            focusedBorder: _border(_ResetColors.primary, width: 1.2),
            errorBorder: _border(const Color(0xffd92d20)),
            focusedErrorBorder: _border(const Color(0xffd92d20), width: 1.2),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = .8}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [_ResetColors.primary, Color(0xff0968c3)],
          ),
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}

abstract final class _ResetLayout {
  static double pagePadding(double width) {
    if (width <= 340) return 16;
    if (width <= 480) return 20;
    return 32;
  }
}

abstract final class _ResetColors {
  static const Color title = Color(0xff131415);
  static const Color label = Color(0xff191e28);
  static const Color muted = Color(0xff98a1b3);
  static const Color tertiary = Color(0xff4b5363);
  static const Color border = Color(0xffe1e2e6);
  static const Color primary = Color(0xff0b83d9);
}
