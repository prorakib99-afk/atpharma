import 'package:flutter/material.dart';

import 'favorite_store.dart';
import 'favourite_screen.dart';

class FavoriteHeaderButton extends StatelessWidget {
  const FavoriteHeaderButton({
    super.key,
    this.size = 40,
    this.iconSize = 20,
    this.borderColor,
    this.inactiveColor = const Color(0xff131415),
  });

  final double size;
  final double iconSize;
  final Color? borderColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoriteStore.instance,
      builder: (BuildContext context, Widget? child) {
        final int count = FavoriteStore.instance.count;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FavouriteScreen(),
                  ),
                );
              },
              customBorder: const CircleBorder(),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: borderColor == null
                      ? null
                      : Border.all(color: borderColor!),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 28,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  count > 0
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: iconSize,
                  color: count > 0 ? const Color(0xffe71c05) : inactiveColor,
                ),
              ),
            ),
            if (count > 0)
              Positioned(
                right: -2,
                top: -3,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17),
                  height: 17,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xffe71c05),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
