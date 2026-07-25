import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FloatingOrderCart extends StatelessWidget {
  const FloatingOrderCart({
    super.key,
    required this.items,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onRemoveItem,
    required this.onContinueShopping,
    required this.onViewFullCart,
    this.currencySymbol = '\$',
    this.taxLabel = 'Taxes Included',
  });

  final List<FloatingCartItem> items;
  final String currencySymbol;
  final String taxLabel;

  final ValueChanged<String> onIncreaseQuantity;
  final ValueChanged<String> onDecreaseQuantity;
  final ValueChanged<String> onRemoveItem;
  final VoidCallback onContinueShopping;
  final VoidCallback onViewFullCart;

  static const Color _primary = Color(0xFF0B83D9);
  static const Color _success = Color(0xFF05962B);
  static const Color _textPrimary = Color(0xFF131314);
  static const Color _textSecondary = Color(0xFF666E80);
  static const Color _border = Color(0xFFE1E2E6);

  int get _totalQuantity {
    return items.fold<int>(0, (int sum, FloatingCartItem item) {
      return sum + item.quantity;
    });
  }

  double get _subtotal {
    return items.fold<double>(0, (double sum, FloatingCartItem item) {
      return sum + (item.unitPrice * item.quantity);
    });
  }

  String _formatPrice(double price) {
    final bool isWholeNumber = price == price.roundToDouble();

    return isWholeNumber
        ? '$currencySymbol${price.toStringAsFixed(0)}'
        : '$currencySymbol${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: screenSize.height * .78,
        ),
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: _border),
                    ),
                    itemBuilder: (_, int index) {
                      return _buildProductSection(items[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, thickness: 1, color: _border),
                  const SizedBox(height: 20),
                  _buildSubtotalSection(),
                  const SizedBox(height: 28),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Cart',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$_totalQuantity ${_totalQuantity == 1 ? 'Item' : 'Items'}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Close cart',
          visualDensity: VisualDensity.compact,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 30, color: _textPrimary),
        ),
      ],
    );
  }

  Widget _buildProductSection(FloatingCartItem item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useCompactLayout = constraints.maxWidth < 345;

        if (useCompactLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProductImage(imagePath: item.productImage),
              const SizedBox(height: 16),
              _buildProductDetails(item),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              height: 134,
              child: _ProductImage(imagePath: item.productImage),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildProductDetails(item)),
          ],
        );
      },
    );
  }

  Widget _buildProductDetails(FloatingCartItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.manufacturerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _success,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatPrice(item.unitPrice),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _QuantitySelector(
              quantity: item.quantity,
              onDecrease: item.quantity > 1
                  ? () => onDecreaseQuantity(item.id)
                  : null,
              onIncrease: () => onIncreaseQuantity(item.id),
            ),
            const Spacer(),
            _DeleteButton(onPressed: () => onRemoveItem(item.id)),
          ],
        ),
      ],
    );
  }

  Widget _buildSubtotalSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                taxLabel,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          _formatPrice(_subtotal),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stackButtons = constraints.maxWidth < 350;

        final Widget continueButton = _CartActionButton(
          label: 'Continue Shopping',
          isOutlined: true,
          onPressed: onContinueShopping,
        );

        final Widget viewCartButton = _CartActionButton(
          label: 'View Full Cart',
          onPressed: onViewFullCart,
        );

        if (stackButtons) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              viewCartButton,
              const SizedBox(height: 12),
              continueButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: continueButton),
            const SizedBox(width: 14),
            Expanded(child: viewCartButton),
          ],
        );
      },
    );
  }
}

class FloatingCartItem {
  const FloatingCartItem({
    required this.id,
    required this.productName,
    required this.manufacturerName,
    required this.productImage,
    required this.unitPrice,
    required this.quantity,
  });

  final String id;
  final String productName;
  final String manufacturerName;
  final String productImage;
  final double unitPrice;
  final int quantity;
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final Uri? uri = Uri.tryParse(imagePath.trim());
    final bool isNetworkImage =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: isNetworkImage
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                cacheWidth: 360,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => const _CartImageFallback(),
              )
            : Image.asset(
                imagePath,
                fit: BoxFit.cover,
                cacheWidth: 360,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => const _CartImageFallback(),
              ),
      ),
    );
  }
}

class _CartImageFallback extends StatelessWidget {
  const _CartImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF3F4F6),
      child: Center(
        child: Icon(
          Icons.medication_outlined,
          size: 42,
          color: Color(0xFF98A1B3),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  static const Color _borderColor = Color(0xFF98A1B3);
  static const Color _textColor = Color(0xFF131314);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(icon: Icons.remove_rounded, onPressed: onDecrease),
          const VerticalDivider(width: 1, thickness: 1, color: _borderColor),
          SizedBox(
            width: 48,
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: _borderColor),
          _QuantityButton(icon: Icons.add_rounded, onPressed: onIncrease),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: SizedBox(
        width: 42,
        height: 44,
        child: Icon(
          icon,
          size: 21,
          color: onPressed == null
              ? const Color(0xFFD1D5DB)
              : const Color(0xFF131314),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFEEEE),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/delete_icon.svg',
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _CartActionButton extends StatelessWidget {
  const _CartActionButton({
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;

  static const Color _primary = Color(0xFF0B83D9);

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary, width: 1.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
