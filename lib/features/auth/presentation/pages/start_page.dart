import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StartPage extends StatelessWidget {
  const StartPage({
    super.key,
    this.onSignInTap,
    this.onGuestTap,
    this.onSignUpTap,
    this.onGoogleTap,
    this.onAppleTap,
    this.onFacebookTap,
  });

  final VoidCallback? onSignInTap;
  final VoidCallback? onGuestTap;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;
  final VoidCallback? onFacebookTap;

  static const _primary = Color(0xff0b83d9);
  static const _primaryDark = Color(0xff005384);
  static const _primaryLight = Color(0xff1896ea);
  static const _primarySoft = Color(0xffe7f3fb);
  static const _textDark = Color(0xff131314);
  static const _subtitleWhite = Color(0xfff7f8fa);
  static const _dividerGray = Color(0xffe5e7eb);
  static const _mutedGray = Color(0xff98a1b3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width >= 600;
            final contentMaxWidth = isTablet ? 480.0 : double.infinity;
            final horizontalPadding = width <= 340 ? 20.0 : 24.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Column(
                  children: [
                    // ---------------- HERO (blue) ----------------
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_primaryDark, _primary, _primaryLight],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          32,
                          horizontalPadding,
                          36,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: constraints.maxWidth - horizontalPadding * 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const _LogoBadge(),
                                const SizedBox(height: 24),
                                const Text(
                                  'Care, Delivered Simply',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 28,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Medicines, wellness and everyday essentials simple, secure and close to you.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 13,
                                    color: _subtitleWhite,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0a000000),
                                        blurRadius: 24,
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _FeatureRow(
                                        'Order without creating an account',
                                      ),
                                      SizedBox(height: 12),
                                      _FeatureRow(
                                        'Upload prescriptions securely',
                                      ),
                                      SizedBox(height: 12),
                                      _FeatureRow(
                                        'Log in for history and live tracking',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ---------------- BOTTOM (white) ----------------
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(color: Color(0x14000000), blurRadius: 29),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            32,
                            horizontalPadding,
                            20,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width:
                                  constraints.maxWidth - horizontalPadding * 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _AuthButton(
                                    label: 'Sign in to your account',
                                    backgroundColor: _primary,
                                    textColor: Colors.white,
                                    onTap: onSignInTap,
                                  ),
                                  const SizedBox(height: 16),
                                  _AuthButton(
                                    label: 'Continue as a guest',
                                    backgroundColor: _primarySoft,
                                    textColor: _primary,
                                    onTap: onGuestTap,
                                  ),
                                  const SizedBox(height: 32),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 1,
                                        color: _dividerGray,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Or sign in with',
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontSize: 12,
                                          color: _mutedGray,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 80,
                                        height: 1,
                                        color: _dividerGray,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _SocialButton(
                                        onTap: onGoogleTap,
                                        child: SvgPicture.asset(
                                          'assets/icons/google_logo.svg',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      _SocialButton(
                                        onTap: onAppleTap,
                                        child: SvgPicture.asset(
                                          'assets/icons/apple_logo.svg',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      _SocialButton(
                                        onTap: onFacebookTap,
                                        child: SvgPicture.asset(
                                          'assets/icons/facebook_logo.svg',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Don’t you have an account? ',
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontSize: 12,
                                          color: _textDark,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: onSignUpTap,
                                        child: const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            decoration: TextDecoration.none,
                                            fontSize: 12,
                                            color: _primary,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// White circular badge holding the app icon, matching the design's logo
/// treatment (the icon asset itself is just the navy/green mark).
class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x1f000000), blurRadius: 16)],
      ),
      padding: const EdgeInsets.all(22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/images/at_pharma_icon.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffe7f3fb),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '✓',
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: 10,
              color: Color(0xff0b83d9),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              decoration: TextDecoration.none,
              fontSize: 13,
              color: Color(0xff131314),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 14,
                  color: textColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular social sign-in button (Google / Apple / Facebook).
class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: Color(0xffe5e7eb))),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 56, height: 56, child: Center(child: child)),
      ),
    );
  }
}
