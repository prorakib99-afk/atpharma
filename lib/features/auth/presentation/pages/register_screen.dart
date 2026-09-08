import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.onSignUp,
    this.isLoading = false,
    this.onGuestTap,
    this.onSignInTap,
    this.onGoogleTap,
    this.onAppleTap,
    this.onFacebookTap,
  });

  final void Function(
    String fullName,
    String phone,
    String email,
    String password,
  )?
  onSignUp;
  final bool isLoading;
  final VoidCallback? onGuestTap;
  final VoidCallback? onSignInTap;
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;
  final VoidCallback? onFacebookTap;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const _primary = Color(0xff0b83d9);
  static const _primaryDark = Color(0xff005384);
  static const _primarySoft = Color(0xffe7f3fb);
  static const _textDark = Color(0xff131314);
  static const _subtitleWhite = Color(0xfff7f8fa);
  static const _dividerGray = Color(0xfff0f2f5);
  static const _mutedGray = Color(0xff98a1b3);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
                        ClipRect(
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              Positioned(
                                top: -60,
                                left: -40,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      width: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                right: -70,
                                child: Container(
                                  width: 260,
                                  height: 260,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      width: 18,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                    vertical: 36,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: Image.asset(
                                            'assets/images/at_pharma_icon.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 26),
                                      const Text(
                                        'Get Started!',
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
                                        'Enter your details to create account',
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
                                'Full Name',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _InputField(
                                controller: _nameController,
                                hint: 'Enter your name',
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Phone',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _InputField(
                                controller: _phoneController,
                                hint: 'Enter phone number',
                                iconAsset: 'assets/icons/phone.svg',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 20),
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
                              const SizedBox(height: 28),
                              _AuthButton(
                                label: 'Sign Up',
                                loading: widget.isLoading,
                                backgroundColor: _primary,
                                textColor: Colors.white,
                                onTap: widget.isLoading
                                    ? null
                                    : () => widget.onSignUp?.call(
                                        _nameController.text,
                                        _phoneController.text,
                                        _emailController.text,
                                        _passwordController.text,
                                      ),
                              ),
                              if (widget.onGuestTap != null) ...[
                                const SizedBox(height: 16),
                                _AuthButton(
                                  label: 'Continue as a guest',
                                  backgroundColor: _primarySoft,
                                  textColor: _primary,
                                  onTap: widget.onGuestTap,
                                ),
                              ],
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
                                      'Or sign up with',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Do you have an account? ',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: _textDark,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: widget.onSignInTap,
                                    child: const Text(
                                      'Sign In',
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

/// Rounded text field with an SVG leading icon, shared by all form fields.
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.iconAsset,
    this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  }) : assert(iconAsset != null || icon != null);

  final TextEditingController controller;
  final String hint;
  final String? iconAsset;
  final IconData? icon;
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
          child: icon != null
              ? Icon(icon, size: 20, color: _hintGray)
              : SvgPicture.asset(
                  iconAsset!,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    _hintGray,
                    BlendMode.srcIn,
                  ),
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

/// Full-width pill button, reused for "Sign Up" and "Continue as a guest".
class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.label,
    this.loading = false,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: loading
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Circular social sign-up button (Google / Apple / Facebook).
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
