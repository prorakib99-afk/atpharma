import 'package:flutter/material.dart';

class ProductDetailsData {
  const ProductDetailsData({
    required this.name,
    required this.image,
    this.description =
        'Helps prevent dehydration and restore body fluids quickly.',
    this.brand = 'FreshLife',
    this.price = 500,
  });

  final String name;
  final String image;
  final String description;
  final String brand;
  final int price;
}

class ProductCart extends ChangeNotifier {
  ProductCart._();
  static final ProductCart instance = ProductCart._();
  final Map<String, int> _items = {};

  int quantityFor(String name) => _items[name] ?? 0;
  int get totalCount => _items.values.fold(0, (sum, value) => sum + value);

  void add(ProductDetailsData product, int quantity) {
    _items.update(
      product.name,
      (value) => value + quantity,
      ifAbsent: () => quantity,
    );
    notifyListeners();
  }
}

class ScreenProductDetails extends StatefulWidget {
  const ScreenProductDetails({super.key, required this.product});
  final ProductDetailsData product;

  @override
  State<ScreenProductDetails> createState() => _ScreenProductDetailsState();
}

class _ScreenProductDetailsState extends State<ScreenProductDetails> {
  int quantity = 1;
  bool favourite = false;

  ProductDetailsData get product => widget.product;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ProductCart.instance,
      builder: (context, _) {
        final added = ProductCart.instance.quantityFor(product.name) > 0;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            leading: _RoundIcon(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
            title: const Text(
              'Product Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            actions: [
              _RoundIcon(
                icon: favourite ? Icons.favorite : Icons.favorite_border,
                color: favourite ? Colors.red : null,
                onTap: () => setState(() => favourite = !favourite),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _RoundIcon(icon: Icons.shopping_cart_outlined, onTap: () {}),
                  if (ProductCart.instance.totalCount > 0)
                    Positioned(
                      right: 2,
                      top: 0,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: _blue,
                        child: Text(
                          '${ProductCart.instance.totalCount}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroImage(image: product.image),
                const SizedBox(height: 24),
                Text(
                  product.brand,
                  style: const TextStyle(
                    color: _green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const _Badge('In stock', dark: true),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: const TextStyle(color: _body, height: 1.55),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Text('★★★★', style: TextStyle(color: Color(0xFFFFA000))),
                    Text('☆', style: TextStyle(color: _body)),
                    SizedBox(width: 8),
                    Text('4.7', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Text(
                      '(120 reviews)',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 8,
                  children: [
                    _Badge('Medicine', blue: true),
                    _Badge('Acetaminophen'),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: _border),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '৳${product.price}',
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '৳${product.price + 150}',
                      style: const TextStyle(
                        color: _body,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Inclusive of all taxes',
                        style: TextStyle(color: _body),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    _QuantityPicker(
                      value: quantity,
                      onMinus: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                      onPlus: quantity < 31
                          ? () => setState(() => quantity++)
                          : null,
                    ),
                    const Spacer(),
                    const Text(
                      '(31 available)',
                      style: TextStyle(color: _body),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Divider(color: _border),
                const SizedBox(height: 12),
                const _LabelValue(label: 'Product Code:', value: 'MDC051'),
                const SizedBox(height: 12),
                const _LabelValue(
                  label: 'Tags:',
                  value: 'Medicine, Fever, Health, Medicare',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SoftButton(
                        icon: favourite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        onTap: () => setState(() => favourite = !favourite),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SoftButton(
                        icon: Icons.share_outlined,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const _TabStrip(),
                const SizedBox(height: 26),
                const _InfoBlock(
                  icon: Icons.medical_information_outlined,
                  color: Color(0xFF72B5F0),
                  title: 'How to Use:',
                  lines: [
                    'Empty one sachet into 1 liter of clean, safe drinking water',
                    'Stir well until the powder is completely dissolved',
                    'Do not boil after mixing',
                  ],
                ),
                const _InfoBlock(
                  icon: Icons.assignment_outlined,
                  color: Color(0xFF61C87A),
                  title: 'Recommended Dosage:',
                  prefix: 'For Adults–',
                  lines: [
                    'Drink frequently as needed to maintain hydration',
                    'Continue use until dehydration symptoms improve',
                    'For children, give small sips frequently',
                  ],
                ),
                const _InfoBlock(
                  icon: Icons.lightbulb_outline,
                  color: Color(0xFFFFC65B),
                  title: 'Usage Tips:',
                  lines: [
                    'Start taking ORS at the first sign of dehydration',
                    'Continue alongside normal diet (if possible)',
                    'Especially useful during diarrhea, vomiting, fever, or heat exposure',
                  ],
                ),
                const _InfoBlock(
                  icon: Icons.shield_outlined,
                  color: Color(0xFFA982E8),
                  title: 'Important Instructions:',
                  lines: [
                    'Use prepared solution within 24 hours',
                    'Store in a clean, covered container',
                    'Do not mix with milk, juice, or flavored drinks',
                    'Always consult a doctor in case of severe dehydration',
                  ],
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Related Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const Center(
                  child: Text(
                    'You may also like our medicine products',
                    style: TextStyle(fontSize: 12, color: _body),
                  ),
                ),
                const SizedBox(height: 16),
                _RelatedProducts(current: product),
                if (added) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2FFF6),
                      border: Border.all(color: const Color(0xFF65C982)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: _green, size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text('Added to cart')),
                        Text(
                          'View Cart',
                          style: TextStyle(
                            color: _blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0x16000000), blurRadius: 18),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: const BorderSide(color: _blue, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          ProductCart.instance.add(product, quantity),
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        added ? Icons.check : Icons.shopping_cart_outlined,
                      ),
                      label: Text(added ? 'Added' : 'Add To Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

const _blue = Color(0xFF0B83D9);
const _green = Color(0xFF05972C);
const _body = Color(0xFF666E80);
const _border = Color(0xFFE1E2E6);

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.image});
  final String image;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AspectRatio(
        aspectRatio: 1.05,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text('1 / 4'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_Dot(active: true), _Dot(), _Dot(), _Dot()],
      ),
    ],
  );
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active ? _blue : const Color(0xFFE4E6EB),
    ),
  );
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    icon: Icon(icon, color: color),
    style: IconButton.styleFrom(
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFF3F4F6)),
      shadowColor: Colors.black12,
      elevation: 2,
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {this.dark = false, this.blue = false});
  final String text;
  final bool dark;
  final bool blue;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: dark ? 10 : 14, vertical: 5),
    decoration: BoxDecoration(
      color: dark
          ? const Color(0xFF131415)
          : blue
          ? const Color(0xFFE7F3FB)
          : const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(dark ? 16 : 8),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: dark ? 11 : 13,
        color: dark
            ? Colors.white
            : blue
            ? _blue
            : const Color(0xFF131415),
      ),
    ),
  );
}

class _QuantityPicker extends StatelessWidget {
  const _QuantityPicker({required this.value, this.onMinus, this.onPlus});
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF98A1B3)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        _QuantityButton('-', onMinus),
        Container(width: 1, color: _border),
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Container(width: 1, color: _border),
        _QuantityButton('+', onPlus),
      ],
    ),
  );
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton(this.text, this.onTap);
  final String text;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      width: 38,
      height: 40,
      child: Center(child: Text(text, style: const TextStyle(fontSize: 18))),
    ),
  );
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      style: const TextStyle(color: Color(0xFF131415), fontFamily: 'Poppins'),
      children: [
        TextSpan(
          text: '$label  ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        TextSpan(
          text: value,
          style: const TextStyle(color: _body),
        ),
      ],
    ),
  );
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon),
    ),
  );
}

class _TabStrip extends StatelessWidget {
  const _TabStrip();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 22)],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Icon(Icons.description_outlined, color: _body),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFF050E54),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.link, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Dosage & Usage',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.comment_outlined, color: _body),
        const Icon(Icons.sync, color: _body),
      ],
    ),
  );
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.color,
    required this.title,
    required this.lines,
    this.prefix,
  });
  final IconData icon;
  final Color color;
  final String title;
  final List<String> lines;
  final String? prefix;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(bottom: 22, top: 4),
    margin: const EdgeInsets.only(bottom: 18),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: _border)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color.withValues(alpha: .14),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (prefix != null) ...[const SizedBox(height: 14), Text(prefix!)],
        const SizedBox(height: 10),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(left: 7, bottom: 5),
            child: Text(
              '•  $line',
              style: const TextStyle(color: _body, height: 1.45),
            ),
          ),
        ),
      ],
    ),
  );
}

class _RelatedProducts extends StatelessWidget {
  const _RelatedProducts({required this.current});
  final ProductDetailsData current;
  @override
  Widget build(BuildContext context) {
    final items = [
      const ProductDetailsData(
        name: 'Organic Honey 500g',
        image: 'assets/images/product_1_opt.jpg',
        description: 'Pure natural honey.',
        brand: "Nature's Own",
        price: 450,
      ),
      const ProductDetailsData(
        name: 'Cefixime 200mg',
        image: 'assets/images/product_6_opt.jpg',
        description: 'Broad-spectrum antibiotic for bacterial infections.',
        brand: 'Square Pharma',
        price: 120,
      ),
      const ProductDetailsData(
        name: 'Metformin 500mg',
        image: 'assets/images/product_7_opt.jpg',
        description: 'Helps control blood sugar levels in type 2 diabetes.',
        brand: 'Beximco Pharma',
        price: 90,
      ),
      const ProductDetailsData(
        name: 'Vitamin D3 60K',
        image: 'assets/images/product_4_opt.jpg',
        description: 'This is a pain energy booster.',
        brand: 'HealthPlus',
        price: 350,
      ),
    ];
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 205,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ScreenProductDetails(product: item),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Color(0x10000000), blurRadius: 12),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                      item.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.brand,
                  style: const TextStyle(fontSize: 9, color: _green),
                ),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFA000), size: 14),
                    const Text('4.8', style: TextStyle(fontSize: 10)),
                    const Spacer(),
                    Text(
                      '৳${item.price}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
