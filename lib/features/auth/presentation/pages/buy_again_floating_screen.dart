import 'package:flutter/material.dart';

Future<void> showFloatingBuyAgainScreen(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .18),
    builder: (_) => const FloatingBuyAgainScreen(),
  );
}

class FloatingBuyAgainScreen extends StatelessWidget {
  const FloatingBuyAgainScreen({super.key});

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: .84,
    minChildSize: .55,
    maxChildSize: .96,
    snap: true,
    expand: false,
    builder: (context, controller) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFE1E2E6))),
        boxShadow: [
          BoxShadow(color: Color(0x19000000), blurRadius: 28, offset: Offset(0, -8)),
        ],
      ),
      child: Column(
        children: [
          _Header(onClose: () => Navigator.pop(context)),
          Expanded(
            child: CustomScrollView(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => _ProductCard(_products[index]),
                      childCount: _products.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      mainAxisExtent: 270,
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverToBoxAdapter(child: _Pagination()),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: SizedBox(
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
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 14, height: 24 / 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buy Again', style: TextStyle(fontSize: 14, height: 24 / 14, fontWeight: FontWeight.w600, color: _Colors.text)),
              Text('Based on your buying & browsing history.', style: TextStyle(fontSize: 12, height: 16 / 12, color: _Colors.body)),
            ],
          ),
        ),
        IconButton(
          onPressed: onClose,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close_rounded, size: 24, color: _Colors.text),
        ),
      ],
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product);
  final _Product product;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: _Colors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 5))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 148,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(product.image, fit: BoxFit.cover, cacheWidth: 320),
                ),
              ),
              Positioned(
                right: -1,
                bottom: -14,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: _Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const Text('FreshLife', style: TextStyle(fontSize: 9, height: 14 / 9, fontWeight: FontWeight.w500, color: Color(0xFF12A150))),
        Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, height: 18 / 12, fontWeight: FontWeight.w600, color: _Colors.text)),
        Text(product.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, height: 16 / 10, color: _Colors.body)),
        const Spacer(),
        const Divider(height: 1, color: _Colors.border),
        const SizedBox(height: 6),
        const Row(
          children: [
            Expanded(child: Text('82 in stock', style: TextStyle(fontSize: 9, color: _Colors.blue))),
            Text('৳500', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _Colors.text)),
          ],
        ),
      ],
    ),
  );
}

class _Pagination extends StatelessWidget {
  const _Pagination();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Row(
        children: [
          _Page('1', active: true), SizedBox(width: 8), _Page('2'), SizedBox(width: 8),
          SizedBox(width: 40, child: Center(child: Text('...'))), SizedBox(width: 8),
          _Page('21'), SizedBox(width: 8), _Page('22'),
        ],
      ),
      const Row(children: [_Arrow(Icons.chevron_left_rounded), SizedBox(width: 16), _Arrow(Icons.chevron_right_rounded)]),
    ],
  );
}

class _Page extends StatelessWidget {
  const _Page(this.label, {this.active = false});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active ? _Colors.blue : _Colors.card,
      shape: BoxShape.circle,
      border: Border.all(color: active ? _Colors.blue : _Colors.border),
    ),
    child: Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.white : _Colors.text)),
  );
}

class _Arrow extends StatelessWidget {
  const _Arrow(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _Colors.text)),
    child: Icon(icon, size: 20, color: _Colors.text),
  );
}

class _Product {
  const _Product(this.image, this.name, this.description);
  final String image;
  final String name;
  final String description;
}

const _products = [
  _Product('assets/images/product_1_opt.jpg', 'Organic Honey 500g', 'Pure natural honey.'),
  _Product('assets/images/product_2_opt.jpg', 'Hand Sanitizer Gel...', 'Kills 99.9% germs.'),
  _Product('assets/images/product_3_opt.jpg', 'ORS Oral Saline Sachet', 'Helps prevent dehydration'),
  _Product('assets/images/product_4_opt.jpg', 'Vitamin D3 60K', 'This is a pain energy booster.'),
  _Product('assets/images/product_7_opt.jpg', 'Metformin 500mg', 'Helps control blood sugar.'),
  _Product('assets/images/product_6_opt.jpg', 'Cefixime 200mg', 'Prescription antibiotic.'),
];

class _Colors {
  static const blue = Color(0xFF0B83D9);
  static const text = Color(0xFF131415);
  static const body = Color(0xFF666E80);
  static const border = Color(0xFFE1E2E6);
  static const card = Color(0xFFF7F8FA);
}
