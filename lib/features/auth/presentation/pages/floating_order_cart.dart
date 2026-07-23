import 'package:flutter/material.dart';

class FloatingOrderCart extends StatelessWidget {
  const FloatingOrderCart({
    super.key,
    required this.productName,
    required this.manufacturerName,
    required this.productImage,
    required this.unitPrice,
    required this.quantity,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onRemoveItem,
    required this.onContinueShopping,
    required this.onViewFullCart,
    this.currencySymbol = '\$',
    this.taxLabel = 'Taxes Included',
  });

  final String productName;
  final String manufacturerName;
  final String productImage;
  final double unitPrice;
  final int quantity;
  final String currencySymbol;
  final String taxLabel;

  final VoidCallback onIncreaseQuantity;
  final VoidCallback onDecreaseQuantity;
  final VoidCallback onRemoveItem;
  final VoidCallback onContinueShopping;
  final VoidCallback onViewFullCart;

  static const Color _primary = Color(0xFF0B83D9);
  static const Color _success = Color(0xFF05962B);
  static const Color _textPrimary = Color(0xFF131314);
  static const Color _textSecondary = Color(0xFF666E80);
  static const Color _border = Color(0xFFE1E2E6);
  static const Color _quantityBorder = Color(0xFF98A1B3);
  static const Color _deleteBackground = Color(0xFFFFEEEE);
  static const Color _deleteColor = Color(0xFFFF3029);

  double get _subtotal => unitPrice * quantity;

  String _formatPrice(double price) {
    final bool isWholeNumber = price == price.roundToDouble();

    return isWholeNumber
        ? '$currencySymbol${price.toStringAsFixed(0)}'
        : '$currencySymbol${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: screenSize.height * 0.90,
        ),
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(28),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildProductSection(),
                const SizedBox(height: 24),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: _border,
                ),
                const SizedBox(height: 20),
                _buildSubtotalSection(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
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
                '$quantity ${quantity == 1 ? 'Item' : 'Items'}',
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
          icon: const Icon(
            Icons.close_rounded,
            size: 30,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildProductSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useCompactLayout = constraints.maxWidth < 345;

        if (useCompactLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProductImage(imagePath: productImage),
              const SizedBox(height: 16),
              _buildProductDetails(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              height: 134,
              child: _ProductImage(imagePath: productImage),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildProductDetails()),
          ],
        );
      },
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          manufacturerName,
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
          productName,
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
          _formatPrice(unitPrice),
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
              quantity: quantity,
              onDecrease: quantity > 1 ? onDecreaseQuantity : null,
              onIncrease: onIncreaseQuantity,
            ),
            const Spacer(),
            _DeleteButton(onPressed: onRemoveItem),
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

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF3F4F6),
              alignment: Alignment.center,
              child: const Icon(
                Icons.medication_outlined,
                size: 42,
                color: Color(0xFF98A1B3),
              ),
            );
          },
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
        border: Border.all(
          color: _borderColor,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove_rounded,
            onPressed: onDecrease,
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: _borderColor,
          ),
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
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: _borderColor,
          ),
          _QuantityButton(
            icon: Icons.add_rounded,
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

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
  const _DeleteButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFEEEE),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.delete_outline_rounded,
            size: 22,
            color: Color(0xFFFF3029),
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
            side: const BorderSide(
              color: _primary,
              width: 1.6,
            ),
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