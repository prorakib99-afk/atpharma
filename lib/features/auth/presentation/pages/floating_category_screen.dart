import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../shop/presentation/controllers/shop_category_store.dart';

Future<void> showFloatingCategoryScreen(BuildContext context) async {
  final ShopCategoryStore store = ShopCategoryStore.instance;
  unawaited(store.load());

  final ShopCategory? category = await showModalBottomSheet<ShopCategory>(
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
    arguments: <String, Object>{
      'categoryIds': category.filterIds,
      'categoryName': category.name,
    },
  );
}

class FloatingCategoryScreen extends StatelessWidget {
  const FloatingCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom;
    final ShopCategoryStore store = ShopCategoryStore.instance;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .78,
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFE1E2E6))),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0x29000000), blurRadius: 32),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AnimatedBuilder(
                  animation: store,
                  builder: (_, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Shop by Category',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          height: 24 / 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF131415),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Browse through our wide range of healthcare '
                        'products and medicines',
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
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
                icon: const Icon(Icons.close, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: AnimatedBuilder(
              animation: store,
              builder: (BuildContext context, _) {
                if (store.isLoading && store.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (store.categories.isEmpty) {
                  return Center(
                    child: TextButton.icon(
                      onPressed: () => store.load(force: true),
                      icon: const Icon(Icons.refresh),
                      label: Text(store.errorMessage ?? 'Retry'),
                    ),
                  );
                }

                return _FigmaCategoryGrid(categories: store.categories);
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B83D9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaCategoryGrid extends StatelessWidget {
  const _FigmaCategoryGrid({required this.categories});

  final List<ShopCategory> categories;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              for (int index = 0; index < 3; index++) ...<Widget>[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: _CategoryCard(
                    category: categories[index],
                    index: index,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (int index = 3; index < 5; index++) ...<Widget>[
                if (index > 3) const SizedBox(width: 8),
                Expanded(
                  child: _CategoryCard(
                    category: categories[index],
                    index: index,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.index});

  final ShopCategory category;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: categoryColorFor(category.name, index),
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
              children: <Widget>[
                CategoryVisual(name: category.name),
                const SizedBox(height: 12),
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${category.count}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
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
}

class CategoryVisual extends StatelessWidget {
  const CategoryVisual({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 34,
      child: Image.asset(
        categoryImageFor(name),
        fit: BoxFit.contain,
        cacheWidth: 80,
      ),
    );
  }
}

String categoryImageFor(String name) {
  final String normalized = name.toLowerCase();

  if (normalized.contains('baby')) {
    return 'assets/images/baby_care_icon_opt.png';
  }
  if (normalized.contains('medicine') ||
      normalized.contains('medecine') ||
      normalized.contains('medical')) {
    return 'assets/images/drug_icon_opt.png';
  }
  if (normalized.contains('general') ||
      normalized.contains('grocery') ||
      normalized.contains('herbal') ||
      normalized.contains('ayurvedic')) {
    return 'assets/images/grocery_icon_opt.png';
  }
  return 'assets/images/skin_care_opt.png';
}

Color categoryColorFor(String name, int index) {
  const List<Color> colors = <Color>[
    Color(0xFFF7FBFE),
    Color(0xFFECFDFD),
    Color(0xFFF8EAFE),
    Color(0xFFFEF0E7),
    Color(0xFFF7FEE7),
  ];

  return colors[index % colors.length];
}
