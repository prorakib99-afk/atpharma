import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/validation/email_validation.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({
    super.key,
    this.onSendCode,
    this.isLoading = false,
    this.message,
    this.isError = false,
  });

  static const String routeName = '/recovery';

  final ValueChanged<String>? onSendCode;
  final bool isLoading;
  final String? message;
  final bool isError;

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isLoading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    widget.onSendCode?.call(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
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
                  _RecoveryLayout.pagePadding(constraints.maxWidth),
                  compact ? 8 : 22,
                  _RecoveryLayout.pagePadding(constraints.maxWidth),
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
                            'assets/images/forgot_password_illustration.png',
                            width: compact ? 232 : 294,
                            height: compact ? 232 : 294,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: compact ? 16 : 30),
                          const _RecoveryHeading(),
                          SizedBox(height: compact ? 24 : 40),
                          _RecoveryField(
                            controller: _controller,
                            enabled: !widget.isLoading,
                            onSubmit: _submit,
                          ),
                          const SizedBox(height: 24),
                          _PrimaryButton(
                            loading: widget.isLoading,
                            onPressed: _submit,
                          ),
                          if (widget.message != null) ...[
                            const SizedBox(height: 16),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                widget.message!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.isError
                                      ? const Color(0xffd92d20)
                                      : _RecoveryColors.body,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          const SizedBox(height: 36),
                          TextButton.icon(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 15,
                            ),
                            label: const Text('Back to Sign In'),
                            style: TextButton.styleFrom(
                              foregroundColor: _RecoveryColors.primary,
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

class _RecoveryHeading extends StatelessWidget {
  const _RecoveryHeading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Forget Password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            height: 28 / 24,
            fontWeight: FontWeight.w600,
            color: _RecoveryColors.title,
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 249,
          child: Text(
            'Enter your registered email to receive a verification code',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              color: _RecoveryColors.body,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecoveryField extends StatelessWidget {
  const _RecoveryField({
    required this.controller,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => onSubmit(),
      validator: EmailValidation.validate,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: _RecoveryColors.title,
      ),
      decoration: InputDecoration(
        hintText: 'Enter email address',
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: _RecoveryColors.muted,
        ),
        prefixIcon: const _EmailPrefix(),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: _border(_RecoveryColors.border),
        focusedBorder: _border(_RecoveryColors.primary, width: 1.2),
        errorBorder: _border(const Color(0xffd92d20)),
        focusedErrorBorder: _border(const Color(0xffd92d20), width: 1.2),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = .8}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _EmailPrefix extends StatelessWidget {
  const _EmailPrefix();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Align(
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icons/email.svg',
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            _RecoveryColors.title,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.loading, required this.onPressed});

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
            colors: [_RecoveryColors.primary, Color(0xff0968c3)],
          ),
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
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
                  'Sent Verification Code',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 24 / 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}

abstract final class _RecoveryLayout {
  static double pagePadding(double width) {
    if (width <= 340) return 16;
    if (width <= 480) return 20;
    return 32;
  }
}

abstract final class _RecoveryColors {
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color muted = Color(0xff98a1b3);
  static const Color border = Color(0xffe1e2e6);
  static const Color primary = Color(0xff0b83d9);
}
