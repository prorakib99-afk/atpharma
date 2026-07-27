import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/routes/app_routes.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key, this.onSendCode});

  static const String routeName = '/recovery';

  final Future<void> Function(String value, bool usePhone)? onSendCode;

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _usePhone = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeMethod(bool usePhone) {
    if (_usePhone == usePhone) return;
    _formKey.currentState?.reset();
    setState(() {
      _usePhone = usePhone;
      _controller.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final value = _controller.text.trim();
      await widget.onSendCode?.call(value, _usePhone);
      if (!mounted) return;
      await Navigator.of(context).pushNamed(
        AppRoutes.otp,
        arguments: _maskedDestination(value),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _maskedDestination(String value) {
    if (_usePhone) {
      final visible = value.length <= 3 ? value : value.substring(0, 3);
      final hidden = List.filled(value.length - visible.length, '*').join();
      return '+966 $visible$hidden';
    }
    final parts = value.split('@');
    if (parts.length != 2) return value;
    final name = parts.first;
    final visible = name.isEmpty ? '' : name[0];
    final hidden = List.filled(name.length - visible.length, '*').join();
    return '$visible$hidden@${parts.last}';
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
                            usePhone: _usePhone,
                            onSubmit: _submit,
                          ),
                          const SizedBox(height: 12),
                          _MethodSwitch(
                            usePhone: _usePhone,
                            onChanged: _changeMethod,
                          ),
                          const SizedBox(height: 24),
                          _PrimaryButton(
                            loading: _isSubmitting,
                            onPressed: _submit,
                          ),
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
            'Enter your registered phone no. or email to get reset code',
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
    required this.usePhone,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool usePhone;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey<bool>(usePhone),
      controller: controller,
      keyboardType: usePhone ? TextInputType.phone : TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      inputFormatters: usePhone
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
          : null,
      onFieldSubmitted: (_) => onSubmit(),
      validator: (value) {
        final input = value?.trim() ?? '';
        if (input.isEmpty) {
          return usePhone
              ? 'Enter your registered phone number'
              : 'Enter your registered email';
        }
        if (usePhone && input.length < 8) return 'Enter a valid phone number';
        if (!usePhone &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(input)) {
          return 'Enter a valid email address';
        }
        return null;
      },
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: _RecoveryColors.title,
      ),
      decoration: InputDecoration(
        hintText: usePhone ? 'Enter phone number' : 'Enter email address',
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: _RecoveryColors.muted,
        ),
        prefixIcon: usePhone ? const _PhonePrefix() : const _EmailPrefix(),
        prefixIconConstraints: BoxConstraints(
          minWidth: usePhone ? 116 : 48,
          minHeight: 48,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

class _PhonePrefix extends StatelessWidget {
  const _PhonePrefix();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/saudi_flag.png',
              width: 24,
              height: 16,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: _RecoveryColors.title,
          ),
          const SizedBox(width: 8),
          const Text(
            '+966',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: _RecoveryColors.muted,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 18, color: _RecoveryColors.border),
        ],
      ),
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

class _MethodSwitch extends StatelessWidget {
  const _MethodSwitch({required this.usePhone, required this.onChanged});

  final bool usePhone;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MethodItem(
          label: 'Phone',
          selected: usePhone,
          onTap: () => onChanged(true),
        ),
        _MethodItem(
          label: 'Email',
          selected: !usePhone,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _MethodItem extends StatelessWidget {
  const _MethodItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _RecoveryColors.primaryLight : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: selected
                  ? _RecoveryColors.primary
                  : _RecoveryColors.title,
            ),
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
  static const Color primaryLight = Color(0xffe7f3fb);
}
