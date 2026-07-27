import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';

Future<void> showFloatingCategoryScreen(BuildContext context) async {
  final _Category? category = await showModalBottomSheet<_Category>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .18),
    builder: (_) => const FloatingCategoryScreen(),
  );
  if (category == null || !context.mounted) return;
  await Navigator.of(context).pushNamed(
    AppRoutes.explore,
    arguments: <String, String>{
      'categoryId': category.id,
      'categoryName': category.apiName,
    },
  );
}

class FloatingCategoryScreen extends StatelessWidget {
  const FloatingCategoryScreen({super.key});

  static const _categories = [
    _Category(
      'cmrdtm3u90000dc06b8txq5c8',
      'Medicines',
      '12',
      'Medicine',
      'assets/images/drug_icon_opt.png',
      Color(0x52E7F3FB),
      40,
    ),
    _Category(
      'cmrf7emim0000hkvp20b5ffet',
      'Grocery',
      '5',
      'Grocery',
      'assets/images/grocery_icon_opt.png',
      Color(0xFFECFEFF),
      32,
    ),
    _Category(
      'cmrf6hrf30000ufw7wnco3wy2',
      'Personal Care',
      '35',
      'Personal Care',
      'assets/images/skin_care_opt.png',
      Color(0xFFF6EAFE),
      32,
    ),
    _Category(
      'cmrf7emiv0001hkvpccx3pmqe',
      'Baby Care',
      '7',
      'Baby Care',
      'assets/images/baby_care_icon_opt.png',
      Color(0xFFFEF0E7),
      32,
    ),
    _Category(
      'cmrf7emiy0002hkvp2m4inznz',
      'Ayurvedic & Herbal',
      '4',
      'Ayurvedic & Herbal',
      'assets/images/grocery_icon_opt.png',
      Color(0xFFF7FEE7),
      32,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFE1E2E6))),
        boxShadow: [BoxShadow(color: Color(0x29000000), blurRadius: 32)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop by Category',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 24 / 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF131415),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Browse through our wide range of healthcare products and medicines',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        height: 16 / 12,
                        color: Color(0xFF666E80),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
                icon: const Icon(
                  Icons.close,
                  size: 24,
                  color: Color(0xFF191E28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var index = 0; index < 3; index++) ...[
                Expanded(child: _CategoryCard(_categories[index])),
                if (index < 2) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _CategoryCard(_categories[3])),
              const SizedBox(width: 8),
              Expanded(child: _CategoryCard(_categories[4])),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B83D9), Color(0xFF0968C3)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard(this.category);
  final _Category category;

  @override
  Widget build(BuildContext context) => Material(
    color: category.color,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: () => Navigator.of(context).pop(category),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 104,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          category.icon,
          width: category.iconWidth,
          height: 32,
          fit: BoxFit.contain,
          cacheWidth: 80,
        ),
        const SizedBox(height: 12),
        Text(
          category.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF131415),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          category.count,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666E80),
          ),
        ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Category {
  const _Category(
    this.id,
    this.title,
    this.count,
    this.apiName,
    this.icon,
    this.color,
    this.iconWidth,
  );

  final String id;
  final String title;
  final String count;
  final String apiName;
  final String icon;
  final Color color;
  final double iconWidth;
}
