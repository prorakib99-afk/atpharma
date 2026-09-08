import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routes/app_routes.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    this.destination = '',
    this.isLoading = false,
    this.resendGeneration = 0,
    this.onVerify,
    this.onResend,
  });

  static const String routeName = '/otp';

  final String destination;
  final bool isLoading;
  final int resendGeneration;
  final Future<void> Function(String code)? onVerify;
  final Future<void> Function()? onResend;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsLeft = 90;
  @override
  void didUpdateWidget(covariant OtpScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resendGeneration != widget.resendGeneration) {
      for (final controller in _controllers) {
        controller.clear();
      }
      _focusNodes.first.requestFocus();
      _startTimer();
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 90);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _code => _controllers.map((item) => item.text).join();

  String get _timerText {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '').split('').take(6);
      var target = 0;
      for (final digit in digits) {
        _controllers[target++].text = digit;
      }
      final focusIndex = target <= 1
          ? 0
          : target >= 6
          ? 5
          : target - 1;
      _focusNodes[focusIndex].requestFocus();
      setState(() {});
      return;
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verify() async {
    if (widget.isLoading) return;
    if (_code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit verification code.')),
      );
      return;
    }
    if (widget.onVerify == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please request a verification code from Sign In or Sign Up.',
          ),
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    await widget.onVerify!(_code);
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || widget.isLoading || widget.onResend == null) return;
    await widget.onResend!();
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
                  _OtpLayout.pagePadding(constraints.maxWidth),
                  compact ? 8 : 22,
                  _OtpLayout.pagePadding(constraints.maxWidth),
                  24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (compact ? 32 : 46),
                  ),
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/otp_verification_illustration.png',
                          width: compact ? 232 : 294,
                          height: compact ? 232 : 294,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: compact ? 16 : 30),
                        _OtpHeading(
                          destination: widget.destination,
                          timerText: _timerText,
                        ),
                        SizedBox(height: compact ? 24 : 40),
                        _OtpFields(
                          controllers: _controllers,
                          focusNodes: _focusNodes,
                          onChanged: _onChanged,
                        ),
                        const SizedBox(height: 24),
                        _VerifyButton(
                          loading: widget.isLoading,
                          onPressed: _verify,
                        ),
                        const SizedBox(height: 16),
                        _ResendButton(
                          enabled:
                              _secondsLeft == 0 &&
                              !widget.isLoading &&
                              widget.onResend != null,
                          onPressed: _resend,
                        ),
                        const SizedBox(height: 36),
                        TextButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.login,
                                (route) => route.isFirst,
                              ),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 15,
                          ),
                          label: const Text('Back to Sign In'),
                          style: TextButton.styleFrom(
                            foregroundColor: _OtpColors.primary,
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OtpHeading extends StatelessWidget {
  const _OtpHeading({required this.destination, required this.timerText});

  final String destination;
  final String timerText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: 249,
          child: Text(
            'Enter 6-digit\nVerification Code',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              height: 28 / 24,
              fontWeight: FontWeight.w600,
              color: _OtpColors.title,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 270,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      'Check your email for the code sent for $destination.\nResend available in ',
                ),
                TextSpan(
                  text: timerText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _OtpColors.title,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              color: _OtpColors.body,
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpFields extends StatelessWidget {
  const _OtpFields({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
          child: SizedBox(
            width:
                (MediaQuery.sizeOf(context).width - 88)
                    .clamp(180, 288)
                    .toDouble() /
                6,
            height: 48,
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              autofocus: index == 0,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: index == 0 ? 6 : 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => onChanged(index, value),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                height: 22 / 18,
                fontWeight: FontWeight.w600,
                color: _OtpColors.title,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                enabledBorder: _border(_OtpColors.border),
                focusedBorder: _border(_OtpColors.primary, width: 1.2),
              ),
            ),
          ),
        );
      }),
    );
  }

  OutlineInputBorder _border(Color color, {double width = .8}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.loading, required this.onPressed});

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
            colors: [_OtpColors.primary, Color(0xff0968c3)],
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
                  'Verify',
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

class _ResendButton extends StatelessWidget {
  const _ResendButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Didn’t receive code? '),
            TextSpan(
              text: 'Resend Code',
              style: TextStyle(
                color: enabled ? _OtpColors.primary : _OtpColors.muted,
              ),
            ),
          ],
        ),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: _OtpColors.title,
        ),
      ),
    );
  }
}

abstract final class _OtpLayout {
  static double pagePadding(double width) {
    if (width <= 340) return 16;
    if (width <= 480) return 20;
    return 32;
  }
}

abstract final class _OtpColors {
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color muted = Color(0xff98a1b3);
  static const Color border = Color(0xffe1e2e6);
  static const Color primary = Color(0xff0b83d9);
}
