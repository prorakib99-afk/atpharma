import 'package:flutter/material.dart';

class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFEBEDF0),
    this.highlightColor = const Color(0xFFF7F8FA),
    this.duration = const Duration(milliseconds: 1200),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: <Color>[
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const <double>[0.1, 0.5, 0.9],
              begin: const Alignment(-1, -0.3),
              end: const Alignment(1, 0.3),
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0,
      0,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE1E2E6),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key, required this.cardColor});

  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SkeletonBox(width: double.infinity, height: 148, borderRadius: 10),
          const SizedBox(height: 15),
          const SkeletonBox(width: 60, height: 9, borderRadius: 4),
          const SizedBox(height: 6),
          const SkeletonBox(width: double.infinity, height: 12, borderRadius: 4),
          const SizedBox(height: 4),
          const SkeletonBox(width: 90, height: 10, borderRadius: 4),
          const Spacer(),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const SkeletonBox(width: 44, height: 9, borderRadius: 4),
              const Spacer(),
              const SkeletonBox(width: 50, height: 14, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}
