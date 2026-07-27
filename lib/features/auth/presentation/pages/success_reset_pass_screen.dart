import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routes/app_routes.dart';

class SuccessResetPassScreen extends StatelessWidget {
  const SuccessResetPassScreen({super.key});

  static const String routeName = '/success-reset-password';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 720;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  _SuccessLayout.pagePadding(constraints.maxWidth),
                  compact ? 70 : 108,
                  _SuccessLayout.pagePadding(constraints.maxWidth),
                  24,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 292,
                      height: 203,
                      child: Image.asset(
                        'assets/images/complete_icon.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    SizedBox(height: compact ? 36 : 60),
                    const Text(
                      'Password Changed!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        height: 28 / 24,
                        fontWeight: FontWeight.w600,
                        color: _SuccessColors.title,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(
                      width: 249,
                      child: Text(
                        'Your password has been changed successfully',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 16 / 12,
                          color: _SuccessColors.body,
                        ),
                      ),
                    ),
                    const SizedBox(height: 56),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              _SuccessColors.primary,
                              Color(0xff0968c3),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.home,
                              (_) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Sign In to your account',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              height: 24 / 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

abstract final class _SuccessLayout {
  static double pagePadding(double width) {
    if (width <= 340) return 16;
    if (width <= 480) return 20;
    return 32;
  }
}

abstract final class _SuccessColors {
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color primary = Color(0xff0b83d9);
}
