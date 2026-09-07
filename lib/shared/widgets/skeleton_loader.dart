import 'package:flutter/material.dart';

/// A shared, non-interactive loading placeholder that respects reduced motion.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final Animation<double> _opacity = Tween<double>(
    begin: 0.45,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading content',
    child: ExcludeSemantics(
      child: IgnorePointer(
        child: FadeTransition(opacity: _opacity, child: widget.child),
      ),
    ),
  );
}

class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 6,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFE5E7EB),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({
    super.key,
    this.columns = 2,
    this.itemCount = 6,
    this.mainAxisExtent = 280,
    this.childAspectRatio = 0.6,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  final int columns;
  final int itemCount;
  final double? mainAxisExtent;
  final double childAspectRatio;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) => SkeletonLoader(
    child: GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: mainAxisExtent,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
      ),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F1F3)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SkeletonBlock(width: double.infinity, radius: 10)),
            SizedBox(height: 16),
            SkeletonBlock(width: 56, height: 9),
            SizedBox(height: 8),
            SkeletonBlock(width: double.infinity, height: 14),
            SizedBox(height: 8),
            SkeletonBlock(width: 80, height: 9),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: SkeletonBlock(height: 16)),
                SizedBox(width: 20),
                SkeletonBlock(width: 30, height: 30, radius: 15),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) => SkeletonLoader(
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (_, _) => const SizedBox(
        width: 72,
        child: Column(
          children: [
            SkeletonBlock(width: 64, height: 64, radius: 32),
            SizedBox(height: 12),
            SkeletonBlock(width: 60, height: 10),
          ],
        ),
      ),
    ),
  );
}
