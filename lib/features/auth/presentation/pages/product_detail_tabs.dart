import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shop_reviews/domain/entities/shop_review_entity.dart';
import '../../../shop_reviews/presentation/bloc/shop_reviews_bloc.dart';
import '../../../shop_reviews/presentation/bloc/shop_reviews_event.dart';
import '../../../shop_reviews/presentation/bloc/shop_reviews_state.dart';

enum ProductDetailTab { description, dosage, reviews, substitutes }

class ProductDetailTabs extends StatefulWidget {
  const ProductDetailTabs({
    super.key,
    required this.productId,
    required this.description,
    required this.dosageUsage,
    required this.substituteMedicines,
  });
  final String productId;
  final String description;
  final String dosageUsage;
  final String substituteMedicines;
  @override
  State<ProductDetailTabs> createState() => _ProductDetailTabsState();
}

class _ProductDetailTabsState extends State<ProductDetailTabs> {
  ProductDetailTab selected = ProductDetailTab.dosage;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopReviewsBloc, ShopReviewsState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message!))),
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TabStrip(
            selected: selected,
            onSelected: (value) => setState(() => selected = value),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _content(context, state),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, ShopReviewsState state) =>
      switch (selected) {
        ProductDetailTab.description => _TextPanel(
          key: const ValueKey('description'),
          title: 'Description',
          text: widget.description,
        ),
        ProductDetailTab.dosage => _TextPanel(
          key: const ValueKey('dosage'),
          title: 'Dosage & Usage',
          text: widget.dosageUsage,
        ),
        ProductDetailTab.reviews => _ReviewsPanel(
          key: const ValueKey('reviews'),
          productId: widget.productId,
          state: state,
        ),
        ProductDetailTab.substitutes => _TextPanel(
          key: const ValueKey('substitutes'),
          title: 'Substitute Medicines',
          text: widget.substituteMedicines,
        ),
      };
}

class _TabStrip extends StatelessWidget {
  const _TabStrip({required this.selected, required this.onSelected});
  final ProductDetailTab selected;
  final ValueChanged<ProductDetailTab> onSelected;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 22)],
    ),
    child: Row(
      children: ProductDetailTab.values
          .map(
            (tab) => Expanded(
              flex: tab == selected ? 4 : 1,
              child: _TabButton(
                tab: tab,
                active: tab == selected,
                onTap: () => onSelected(tab),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.active,
    required this.onTap,
  });
  final ProductDetailTab tab;
  final bool active;
  final VoidCallback onTap;
  IconData get icon => switch (tab) {
    ProductDetailTab.description => Icons.description_outlined,
    ProductDetailTab.dosage => Icons.link_rounded,
    ProductDetailTab.reviews => Icons.comment_outlined,
    ProductDetailTab.substitutes => Icons.sync_rounded,
  };
  String get label => switch (tab) {
    ProductDetailTab.description => 'Description',
    ProductDetailTab.dosage => 'Dosage & Usage',
    ProductDetailTab.reviews => 'Reviews',
    ProductDetailTab.substitutes => 'Substitute Medicines',
  };
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: Material(
      color: active ? const Color(0xFF050E54) : const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: active ? 10 : 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: active ? Colors.white : const Color(0xFF666E80),
              ),
              if (active) ...[
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _TextPanel extends StatelessWidget {
  const _TextPanel({super.key, required this.title, required this.text});
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          text.trim().isEmpty ? 'No information available.' : text,
          style: const TextStyle(color: Color(0xFF666E80), height: 1.5),
        ),
      ],
    ),
  );
}

class _ReviewsPanel extends StatelessWidget {
  const _ReviewsPanel({
    super.key,
    required this.productId,
    required this.state,
  });
  final String productId;
  final ShopReviewsState state;
  @override
  Widget build(BuildContext context) {
    if (state.status == ShopReviewsStatus.loading && state.page == null) {
      return const _Panel(child: Center(child: CircularProgressIndicator()));
    }
    final page = state.page;
    if (page == null) {
      return _Panel(
        child: Center(
          child: TextButton(
            onPressed: () => context.read<ShopReviewsBloc>().add(
              ShopReviewsRequested(productId),
            ),
            child: const Text('Retry loading reviews'),
          ),
        ),
      );
    }
    return Column(
      children: [
        _ReviewSummary(summary: page.summary),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: state.status == ShopReviewsStatus.submitting
                ? null
                : () => _showReviewDialog(context),
            icon: const Icon(Icons.star_outline_rounded),
            label: Text(
              state.status == ShopReviewsStatus.submitting
                  ? 'Submitting...'
                  : 'Write a Review',
            ),
          ),
        ),
        if (page.items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'No reviews yet.',
              style: TextStyle(color: Color(0xFF666E80)),
            ),
          )
        else
          ...page.items.map((review) => _ReviewCard(review: review)),
      ],
    );
  }

  Future<void> _showReviewDialog(BuildContext context) async {
    var rating = 5;
    final title = TextEditingController();
    final comment = TextEditingController();
    final bloc = context.read<ShopReviewsBloc>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Write a Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: () => setDialogState(() => rating = index + 1),
                      icon: Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFFFA000),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Title (optional)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: comment,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.pop(dialogContext);
                bloc.add(
                  ShopReviewSubmitted(
                    productId: productId,
                    rating: rating,
                    title: title.text,
                    comment: comment.text,
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    comment.dispose();
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.summary});
  final ShopReviewSummary summary;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Row(
      children: [
        Column(
          children: [
            Text(
              summary.average.toStringAsFixed(1),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < summary.average.round()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 18,
                  color: const Color(0xFFFFA000),
                ),
              ),
            ),
            Text(
              '${summary.count} reviews',
              style: const TextStyle(color: Color(0xFF666E80)),
            ),
          ],
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            children: [
              for (var rating = 5; rating >= 1; rating--)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(width: 12, child: Text('$rating')),
                      const SizedBox(width: 6),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: summary.count == 0
                              ? 0
                              : (summary.breakdown[rating] ?? 0) /
                                    summary.count,
                          backgroundColor: const Color(0xFFF1F3F6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 22,
                        child: Text('${summary.breakdown[rating] ?? 0}'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final ShopReviewEntity review;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.customerName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              ...List.generate(
                5,
                (i) => Icon(
                  i < review.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 16,
                  color: const Color(0xFFFFA000),
                ),
              ),
            ],
          ),
          if (review.title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              review.comment,
              style: const TextStyle(color: Color(0xFF666E80)),
            ),
          ],
        ],
      ),
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE1E2E6)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );
}
