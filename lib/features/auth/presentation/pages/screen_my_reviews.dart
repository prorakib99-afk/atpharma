import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../shop_reviews/domain/entities/my_review_entity.dart';
import '../../../shop_reviews/presentation/bloc/my_reviews_bloc.dart';
import '../../../shop_reviews/presentation/bloc/my_reviews_event.dart';
import '../../../shop_reviews/presentation/bloc/my_reviews_state.dart';
import 'product_detail_tabs.dart';
import 'screen_product_details.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  static const String routeName = AppRoutes.myReviews;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyReviewsBloc>(
      create: (_) => sl<MyReviewsBloc>()..add(const MyReviewsRequested()),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6faff),
      body: BlocConsumer<MyReviewsBloc, MyReviewsState>(
        listener: (BuildContext context, MyReviewsState state) {
          final String? message = state.message;
          if (message != null && message.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (BuildContext context, MyReviewsState state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<MyReviewsBloc>().add(
                const MyReviewsRequested(refresh: true),
              );
              await context.read<MyReviewsBloc>().stream.firstWhere(
                (MyReviewsState s) => s.status != MyReviewsStatus.loading,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                const SliverToBoxAdapter(child: _Header()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  sliver: SliverList.list(
                    children: <Widget>[
                      if (state.status == MyReviewsStatus.loading &&
                          state.reviews.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state.status == MyReviewsStatus.failure &&
                          state.reviews.isEmpty)
                        _Error(
                          message: state.message ?? 'Could not load reviews',
                          retry: () => context.read<MyReviewsBloc>().add(
                            const MyReviewsRequested(),
                          ),
                        )
                      else if (state.reviews.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text('No reviews yet'),
                          ),
                        )
                      else
                        for (final MyReviewEntity review in state.reviews) ...[
                          _ReviewCard(
                            review: review,
                            deleting: state.deletingReviewId == review.id,
                          ),
                          const SizedBox(height: 16),
                        ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 290,
    child: Stack(
      children: <Widget>[
        Container(
          height: 278,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/sky.png'),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(300, 70),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 10,
          left: 24,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xff087cf0),
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Column(
            children: <Widget>[
              Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x240c4f8e),
                      blurRadius: 18,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/images/at_pharma_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'My Reviews',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff0f1530),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your feedback helps us serve you better',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xff667a9b), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.deleting});

  final MyReviewEntity review;
  final bool deleting;

  void _openProductPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScreenProductDetails(
          product: ProductDetailsData(
            id: review.productId.isEmpty ? null : review.productId,
            name: review.productName,
            image: review.productImageUrl,
          ),
          initialTab: ProductDetailTab.reviews,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete review'),
        content: const Text(
          'Are you sure you want to delete this review? This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xffe04454)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<MyReviewsBloc>().add(
        MyReviewDeleteRequested(reviewId: review.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = review.published
        ? const Color(0xff14945f)
        : const Color(0xffb9820b);
    final String statusLabel = review.published
        ? 'Published'
        : 'Pending approval';

    return Opacity(
      opacity: deleting ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ProductThumb(
                  imageUrl: review.productImageUrl,
                  name: review.productName,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        review.productName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff0f1530),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List<Widget>.generate(
                          5,
                          (int index) => Icon(
                            index < review.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xfff5a623),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (review.title.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff0f1530),
                ),
              ),
            ],
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                review.comment,
                style: const TextStyle(color: Color(0xff667a9b), fontSize: 13),
              ),
            ],
            const Divider(height: 24, color: Color(0xffe4ebf4)),
            Row(
              children: <Widget>[
                InkWell(
                  onTap: deleting ? null : () => _openProductPage(context),
                  child: const Row(
                    children: <Widget>[
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Color(0xff2264f5),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Edit on product page',
                        style: TextStyle(
                          color: Color(0xff2264f5),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(width: 1, height: 16, color: const Color(0xffe4ebf4)),
                const SizedBox(width: 14),
                InkWell(
                  onTap: deleting ? null : () => _confirmDelete(context),
                  child: const Row(
                    children: <Widget>[
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: Color(0xffe04454),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Color(0xffe04454),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl, required this.name});

  final String imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _InitialAvatar(name: name),
        ),
      );
    }
    return _InitialAvatar(name: name);
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final String initial = name.trim().isEmpty
        ? '?'
        : name.trim()[0].toUpperCase();
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xffe8f0ff),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xff2264f5),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Padding(padding: const EdgeInsets.all(24), child: Text(message)),
      TextButton(onPressed: retry, child: const Text('Try again')),
    ],
  );
}

final BoxDecoration _cardDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xffe7edf6)),
  borderRadius: BorderRadius.circular(20),
  boxShadow: const <BoxShadow>[
    BoxShadow(color: Color(0x1a263b8c), blurRadius: 24, offset: Offset(0, 8)),
  ],
);
