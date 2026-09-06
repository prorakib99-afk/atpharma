import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CartFlyTarget {
  CartFlyTarget._();

  static final ValueNotifier<int> arrivals = ValueNotifier<int>(0);
  static RenderBox? renderBox;

  static void shake() => arrivals.value++;
}

class CartFlyTargetMarker extends SingleChildRenderObjectWidget {
  const CartFlyTargetMarker({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CartFlyTargetRenderBox();
  }
}

class _CartFlyTargetRenderBox extends RenderProxyBox {
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    CartFlyTarget.renderBox = this;
  }

  @override
  void detach() {
    if (identical(CartFlyTarget.renderBox, this)) {
      CartFlyTarget.renderBox = null;
    }
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Routes kept below the current Navigator route can remain attached.
    // The marker that is actually painted is the visible cart destination.
    CartFlyTarget.renderBox = this;
    super.paint(context, offset);
  }
}

Future<void> flyToCart(
  BuildContext context, {
  required String imageUrl,
  VoidCallback? onArrived,
}) async {
  final OverlayState overlay = Overlay.of(context);
  final RenderBox? source = context.findRenderObject() as RenderBox?;
  if (source == null || !source.hasSize) {
    onArrived?.call();
    return;
  }

  final Offset start = source.localToGlobal(source.size.center(Offset.zero));
  final RenderBox? target = CartFlyTarget.renderBox;
  final Size screen = MediaQuery.sizeOf(context);
  final EdgeInsets screenPadding = MediaQuery.paddingOf(context);
  final Offset fallbackEnd = Offset(
    screen.width - 54,
    screen.height - screenPadding.bottom - 56,
  );
  Offset end = fallbackEnd;

  if (target != null && target.attached && target.hasSize) {
    final Offset candidate = target.localToGlobal(
      target.size.center(Offset.zero),
    );
    final bool isInsideCartZone =
        candidate.dx >= screen.width * .68 &&
        candidate.dx <= screen.width &&
        candidate.dy >= screen.height * .70 &&
        candidate.dy <= screen.height;

    if (isInsideCartZone) {
      end = candidate;
    }
  }
  final Completer<void> completer = Completer<void>();
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (BuildContext context) => _FlyingProduct(
      start: start,
      end: end,
      imageUrl: imageUrl,
      onComplete: () {
        entry.remove();
        CartFlyTarget.shake();
        onArrived?.call();
        completer.complete();
      },
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

class _FlyingProduct extends StatefulWidget {
  const _FlyingProduct({
    required this.start,
    required this.end,
    required this.imageUrl,
    required this.onComplete,
  });

  final Offset start;
  final Offset end;
  final String imageUrl;
  final VoidCallback onComplete;

  @override
  State<_FlyingProduct> createState() => _FlyingProductState();
}

class _FlyingProductState extends State<_FlyingProduct>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 620),
        )..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) widget.onComplete();
        });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final double t = Curves.easeInOutCubic.transform(_controller.value);
            final Offset position = Offset.lerp(widget.start, widget.end, t)!;
            final double lift = -80 * 4 * t * (1 - t);
            final double size = 32 - (8 * t);

            return Align(
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: Offset(
                  position.dx - size / 2,
                  position.dy - size / 2 + lift,
                ),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Opacity(
                    opacity: 1 - (0.15 * t),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B83D9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(color: Color(0x500B83D9), blurRadius: 12),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
