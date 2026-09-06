import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onSignIn,
    this.onForgetPassword,
    this.onSignUpTap,
    this.onGoogleTap,
    this.onAppleTap,
    this.onFacebookTap,
    this.initialIdentifier,
    this.initialRememberMe = false,
    this.isLoading = false,
  });

  final void Function(String email, String password, bool rememberMe)? onSignIn;
  final VoidCallback? onForgetPassword;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;
  final VoidCallback? onFacebookTap;
  final String? initialIdentifier;
  final bool initialRememberMe;
  final bool isLoading;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  static const _primary = Color(0xff0b83d9);
  static const _primaryDark = Color(0xff005384);
  static const _textDark = Color(0xff131314);
  static const _subtitleWhite = Color(0xfff7f8fa);
  static const _dividerGray = Color(0xfff0f2f5);
  static const _mutedGray = Color(0xff98a1b3);

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialIdentifier ?? '';
    _rememberMe = widget.initialRememberMe;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryDark, _primary],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isTablet = width >= 600;
              final contentMaxWidth = isTablet ? 480.0 : double.infinity;
              final horizontalPadding = width <= 340 ? 20.0 : 24.0;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ---------------- HERO (blue) ----------------
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            28,
                            horizontalPadding,
                            44,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 104,
                                height: 104,
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x22000000),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/images/at_pharma_icon.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              const Text(
                                'Welcome Back!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Please sign in to your account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: _subtitleWhite,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ---------------- FORM (white) ----------------
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(56),
                              topRight: Radius.circular(56),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 29,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            32,
                            horizontalPadding,
                            28,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _InputField(
                                controller: _emailController,
                                hint: 'example@gmail.com',
                                iconAsset: 'assets/icons/email.svg',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _InputField(
                                controller: _passwordController,
                                hint: 'Enter your password',
                                iconAsset: 'assets/icons/lock.svg',
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: _mutedGray,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            activeColor: _primary,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            onChanged: (v) => setState(
                                              () => _rememberMe = v ?? false,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Flexible(
                                          child: Text(
                                            'Remember me',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              color: _textDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: widget.onForgetPassword,
                                    child: const Text(
                                      'Forget Password?',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: _primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26),
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: widget.isLoading
                                      ? null
                                      : () => widget.onSignIn?.call(
                                          _emailController.text,
                                          _passwordController.text,
                                          _rememberMe,
                                        ),
                                  child: widget.isLoading
                                      ? const SizedBox.square(
                                          dimension: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(
                                      color: _dividerGray,
                                      thickness: 2,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'Or sign in with',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: _mutedGray,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      color: _dividerGray,
                                      thickness: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26),
                              Wrap(
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                children: [
                                  _SocialButton(
                                    onTap: widget.onGoogleTap,
                                    child: SvgPicture.asset(
                                      'assets/icons/google_logo.svg',
                                      width: 28,
                                      height: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _SocialButton(
                                    onTap: widget.onAppleTap,
                                    child: SvgPicture.asset(
                                      'assets/icons/apple_logo.svg',
                                      width: 28,
                                      height: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _SocialButton(
                                    onTap: widget.onFacebookTap,
                                    child: SvgPicture.asset(
                                      'assets/icons/facebook_logo.svg',
                                      width: 28,
                                      height: 28,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26),
                              Wrap(
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                children: [
                                  const Text(
                                    'Don’t you have an account? ',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: _textDark,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: widget.onSignUpTap,
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

/// Rounded text field with an SVG leading icon, shared by the Email and
/// Password fields.
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.iconAsset,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final String iconAsset;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  static const _hintGray = Color(0xff9aa3af);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        color: Color(0xff131314),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          color: _hintGray,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: SvgPicture.asset(
            iconAsset,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(_hintGray, BlendMode.srcIn),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 20,
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xff0b83d9), width: 1.4),
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
      shape: const CircleBorder(
        side: BorderSide(color: Color(0xffe5e7eb), width: 1.4),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 60, height: 60, child: Center(child: child)),
      ),
    );
  }
}
