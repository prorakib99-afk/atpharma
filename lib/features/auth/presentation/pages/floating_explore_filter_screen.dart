import 'dart:async';

import 'package:flutter/material.dart';

import '../../../shop/presentation/controllers/shop_category_store.dart';

class ExploreFilter {
  const ExploreFilter({
    this.categoryIds = const <String>[],
    this.featured,
    this.availability,
    this.prescription,
    this.minPrice,
    this.maxPrice,
  });

  final List<String> categoryIds;
  final bool? featured;
  final bool? availability;
  final bool? prescription;
  final double? minPrice;
  final double? maxPrice;

  int get activeCount =>
      categoryIds.length +
      (featured == null ? 0 : 1) +
      (availability == null ? 0 : 1) +
      (prescription == null ? 0 : 1) +
      (minPrice == null && maxPrice == null ? 0 : 1);
}

Future<ExploreFilter?> showFloatingExploreFilterScreen(
  BuildContext context, {
  ExploreFilter initial = const ExploreFilter(),
  int productCount = 0,
}) {
  return showModalBottomSheet<ExploreFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .16),
    builder: (_) => FloatingExploreFilterScreen(
      initial: initial,
      productCount: productCount,
    ),
  );
}

class FloatingExploreFilterScreen extends StatefulWidget {
  const FloatingExploreFilterScreen({
    super.key,
    required this.initial,
    required this.productCount,
  });

  final ExploreFilter initial;
  final int productCount;

  @override
  State<FloatingExploreFilterScreen> createState() =>
      _FloatingExploreFilterScreenState();
}

class _FloatingExploreFilterScreenState
    extends State<FloatingExploreFilterScreen> {
  final ShopCategoryStore _categoryStore = ShopCategoryStore.instance;
  late Set<String> _categories;
  String? _featured;
  String? _availability;
  String? _prescription;
  late RangeValues _price;

  @override
  void initState() {
    super.initState();
    _categories = widget.initial.categoryIds.toSet();
    if (_categories.isEmpty) _categories.add(_allCategoriesId);
    unawaited(_categoryStore.load());
    _featured = widget.initial.featured == null
        ? null
        : (widget.initial.featured! ? 'Featured' : 'Not-Featured');
    _availability = widget.initial.availability == null
        ? null
        : (widget.initial.availability! ? 'In Stock' : 'Out of Stock');
    _prescription = widget.initial.prescription == null
        ? null
        : (widget.initial.prescription! ? 'Rx Required' : 'No Rx Required');
    _price = RangeValues(
      widget.initial.minPrice ?? 0,
      widget.initial.maxPrice ?? 1000,
    );
  }

  void _reset() => setState(() {
    _categories
      ..clear()
      ..add(_allCategoriesId);
    _featured = null;
    _availability = null;
    _prescription = null;
    _price = const RangeValues(0, 1000);
  });

  ExploreFilter get _result => ExploreFilter(
    categoryIds: _categories
        .where((id) => id != _allCategoriesId)
        .toList(growable: false),
    featured: _featured == null ? null : _featured == 'Featured',
    availability: _availability == null ? null : _availability == 'In Stock',
    prescription: _prescription == null ? null : _prescription == 'Rx Required',
    minPrice: _price.start <= 0 ? null : _price.start,
    maxPrice: _price.end >= 1000 ? null : _price.end,
  );

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: .72,
    minChildSize: .55,
    maxChildSize: .94,
    snap: true,
    expand: false,
    builder: (context, controller) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.fromBorderSide(BorderSide(color: _Colors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 28,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Expanded(child: Text('Filters', style: _Text.section)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 24),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: _Colors.border,
          ),
          Expanded(
            child: ListView(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              children: [
                const Text('Categories', style: _Text.section),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _categoryStore,
                  builder: (BuildContext context, _) {
                    final List<Widget> options = <Widget>[
                      _CategoryOption(
                        label: 'All Products',
                        selected: _categories.contains(_allCategoriesId),
                        onTap: () => setState(() {
                          _categories
                            ..clear()
                            ..add(_allCategoriesId);
                        }),
                      ),
                      ..._categoryStore.categories.map(
                        (ShopCategory category) => _CategoryOption(
                          label: category.name,
                          selected: _categories.contains(category.id),
                          onTap: () => setState(() {
                            _categories.remove(_allCategoriesId);
                            _categories.contains(category.id)
                                ? _categories.remove(category.id)
                                : _categories.add(category.id);
                            if (_categories.isEmpty) {
                              _categories.add(_allCategoriesId);
                            }
                          }),
                        ),
                      ),
                    ];
                    return GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 5.2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 16,
                      children: options,
                    );
                  },
                ),
                const _Line(),
                const Text('Featured Options', style: _Text.section),
                const SizedBox(height: 12),
                _ChoiceRow(
                  values: const ['Featured', 'Not-Featured'],
                  selected: _featured,
                  onChanged: (value) => setState(
                    () => _featured = _featured == value ? null : value,
                  ),
                ),
                const _Line(),
                const Text('Price Range', style: _Text.section),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _PriceBox('\$${_price.start.round()}')),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('—', style: TextStyle(fontSize: 20)),
                    ),
                    Expanded(child: _PriceBox('\$${_price.end.round()}')),
                  ],
                ),
                RangeSlider(
                  values: _price,
                  min: 0,
                  max: 1000,
                  divisions: 100,
                  activeColor: _Colors.blue,
                  inactiveColor: _Colors.border,
                  onChanged: (value) => setState(() => _price = value),
                ),
                const _Line(),
                const Text('Availability', style: _Text.section),
                const SizedBox(height: 12),
                _ChoiceRow(
                  values: const ['In Stock', 'Out of Stock'],
                  selected: _availability,
                  onChanged: (value) => setState(
                    () => _availability = _availability == value ? null : value,
                  ),
                ),
                const _Line(),
                const Text('Prescription', style: _Text.section),
                const SizedBox(height: 12),
                _ChoiceRow(
                  values: const ['Rx Required', 'No Rx Required'],
                  selected: _prescription,
                  onChanged: (value) => setState(
                    () => _prescription = _prescription == value ? null : value,
                  ),
                ),
                const _Line(),
                Center(
                  child: Text(
                    'Showing ${widget.productCount} Products',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: _buttonStyle(false),
                    child: const Text('Reset Filter'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _result),
                    style: _buttonStyle(true),
                    child: const Text('Apply Filter'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  ButtonStyle _buttonStyle(bool filled) =>
      (filled ? ElevatedButton.styleFrom() : OutlinedButton.styleFrom())
          .copyWith(
            minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: WidgetStatePropertyAll(
              filled ? _Colors.blue : Colors.white,
            ),
            foregroundColor: WidgetStatePropertyAll(
              filled ? Colors.white : _Colors.blue,
            ),
            side: const WidgetStatePropertyAll(
              BorderSide(color: _Colors.blue, width: 1.5),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: selected ? _Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected ? _Colors.blue : _Colors.border,
              width: 1.5,
            ),
          ),
          child: selected
              ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14,
              color: selected ? _Colors.blue : _Colors.body,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.values,
    required this.selected,
    required this.onChanged,
  });
  final List<String> values;
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: values
        .map(
          (value) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: value == values.first ? 8 : 0),
              child: InkWell(
                onTap: () => onChanged(value),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value == selected ? _Colors.blue : _Colors.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: value == selected ? Colors.white : _Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _PriceBox extends StatelessWidget {
  const _PriceBox(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    height: 36,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(color: _Colors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(value, style: const TextStyle(fontSize: 14)),
  );
}

class _Line extends StatelessWidget {
  const _Line();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Divider(height: 1, color: _Colors.border),
  );
}

const String _allCategoriesId = '__all_categories__';

class _Colors {
  static const blue = Color(0xFF0B83D9);
  static const body = Color(0xFF666E80);
  static const border = Color(0xFFE1E2E6);
  static const card = Color(0xFFF7F8FA);
}

class _Text {
  static const section = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF131415),
  );
}
