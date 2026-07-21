import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.nextRoute,
    this.displayDuration = const Duration(milliseconds: 3200),
  });

  final String nextRoute;
  final Duration displayDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color _brandBlue = Color(0xFF1A5085);
  static const Color _brandGreen = Color(0xFF128644);
  static const Color _primaryText = Color(0xFF666E80);
  static const Color _secondaryText = Color(0xFF98A1B3);
  static const Color _progressBackground = Color(0xFFE1EBF2);
  static const String _logoAssetPath = 'assets/images/at_pharma_icon.png';
  static const Duration _animationDuration = Duration(milliseconds: 2200);

  late final AnimationController _animationController;
  late final Animation<double> _containerOpacity;
  late final Animation<double> _containerScale;
  late final Animation<double> _containerTranslation;
  late final Animation<double> _blueRingOpacity;
  late final Animation<double> _blueRingScale;
  late final Animation<double> _greenRingOpacity;
  late final Animation<double> _greenRingScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _brandAtOpacity;
  late final Animation<Offset> _brandAtOffset;
  late final Animation<double> _brandPharmaOpacity;
  late final Animation<Offset> _brandPharmaOffset;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineOffset;
  late final Animation<double> _trackOpacity;
  late final Animation<double> _trackScaleX;
  late final Animation<double> _progressValue;
  late final Animation<double> _supportOpacity;
  late final Animation<Offset> _supportOffset;

  Timer? _navigationTimer;
  bool _hasNavigated = false;
  bool _hasInitialized = false;
  bool _animationsEnabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasInitialized) {
      return;
    }

    _hasInitialized = true;
    _animationsEnabled = !MediaQuery.of(context).disableAnimations;

    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _containerOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );

    _containerTranslation = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _containerScale =
        TweenSequence<double>([
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: 0.82,
              end: 1.03,
            ).chain(CurveTween(curve: Curves.easeOutBack)),
            weight: 75,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: 1.03,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 25,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.25),
          ),
        );

    _blueRingOpacity = Tween<double>(begin: 0.0, end: 0.10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.055, 0.318, curve: Curves.easeOut),
      ),
    );

    _blueRingScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.055, 0.318, curve: Curves.easeOut),
      ),
    );

    _greenRingOpacity = Tween<double>(begin: 0.0, end: 0.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.135, 0.318, curve: Curves.easeOut),
      ),
    );

    _greenRingScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.135, 0.318, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.127, 0.34, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.127, 0.34, curve: Curves.easeOutCubic),
      ),
    );

    _brandAtOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.318, 0.545, curve: Curves.easeOutCubic),
      ),
    );

    _brandAtOffset =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.318, 0.545, curve: Curves.easeOutCubic),
          ),
        );

    _brandPharmaOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.385, 0.58, curve: Curves.easeOutCubic),
      ),
    );

    _brandPharmaOffset =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.385, 0.58, curve: Curves.easeOutCubic),
          ),
        );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.477, 0.659, curve: Curves.easeOutCubic),
      ),
    );

    _taglineOffset =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.477, 0.659, curve: Curves.easeOutCubic),
          ),
        );

    _trackOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.614, 0.75, curve: Curves.easeOut),
      ),
    );

    _trackScaleX = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.614, 0.75, curve: Curves.easeOut),
      ),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 0.62).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.682, 0.955, curve: Curves.easeInOutCubic),
      ),
    );

    _supportOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.773, 0.977, curve: Curves.easeOut),
      ),
    );

    _supportOffset =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.773, 0.977, curve: Curves.easeOut),
          ),
        );

    precacheImage(const AssetImage(_logoAssetPath), context).whenComplete(() {
      if (!mounted) {
        return;
      }

      if (_animationsEnabled) {
        _animationController.forward();
      } else {
        _animationController.value = 1.0;
      }

      _navigationTimer = Timer(widget.displayDuration, _navigateToNextScreen);
    });
  }

  void _navigateToNextScreen() {
    if (!mounted || _hasNavigated) {
      return;
    }

    _hasNavigated = true;
    Navigator.of(context).pushReplacementNamed(widget.nextRoute);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final double logoContainerSize = maxWidth * 0.42;
              final double clampedLogoSize = logoContainerSize.clamp(
                152.0,
                220.0,
              );

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: maxWidth < 360 ? 16 : 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _containerOpacity.value,
                              child: Transform.translate(
                                offset: Offset(0, _containerTranslation.value),
                                child: Transform.scale(
                                  scale: _containerScale.value,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: RepaintBoundary(
                            child: _buildLogoPanel(clampedLogoSize),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SlideTransition(
                              position: _brandAtOffset,
                              child: FadeTransition(
                                opacity: _brandAtOpacity,
                                child: const Text(
                                  'AT',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                    color: _brandBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SlideTransition(
                              position: _brandPharmaOffset,
                              child: FadeTransition(
                                opacity: _brandPharmaOpacity,
                                child: const Text(
                                  'PHARMA',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 34,
                                    fontWeight: FontWeight.w600,
                                    color: _brandGreen,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        SlideTransition(
                          position: _taglineOffset,
                          child: FadeTransition(
                            opacity: _taglineOpacity,
                            child: const Text(
                              'Medicine  •  Wellness  •  Care',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _primaryText,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        FadeTransition(
                          opacity: _trackOpacity,
                          child: AnimatedBuilder(
                            animation: _trackScaleX,
                            builder: (context, child) {
                              return Transform.scale(
                                scaleX: _trackScaleX.value,
                                alignment: Alignment.centerLeft,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 88,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _progressBackground,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedBuilder(
                                  animation: _progressValue,
                                  builder: (context, child) {
                                    return FractionallySizedBox(
                                      widthFactor: _progressValue.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
                                          gradient: const LinearGradient(
                                            colors: [_brandBlue, _brandGreen],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        SlideTransition(
                          position: _supportOffset,
                          child: FadeTransition(
                            opacity: _supportOpacity,
                            child: const Text(
                              'Your trusted pharmacy companion',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _secondaryText,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
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

  Widget _buildLogoPanel(double size) {
    final double ringLarge = size * 1.8;
    final double ringSmall = size * 1.3;

    return SizedBox(
      width: ringLarge,
      height: ringLarge,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: _blueRingOpacity,
            child: ScaleTransition(
              scale: _blueRingScale,
              child: _buildRing(ringLarge, _brandBlue.withAlpha(20)),
            ),
          ),
          FadeTransition(
            opacity: _greenRingOpacity,
            child: ScaleTransition(
              scale: _greenRingScale,
              child: _buildRing(ringSmall, _brandGreen.withAlpha(20)),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(26, 80, 133, 0.10),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Semantics(
                    label: 'AT Pharma logo mark',
                    image: true,
                    child: Image.asset(
                      _logoAssetPath,
                      width: size * 0.48,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRing(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.0),
      ),
    );
  }
}
