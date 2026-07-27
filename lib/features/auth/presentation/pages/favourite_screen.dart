import 'package:flutter/material.dart';

import 'favorite_store.dart';
import 'screen_product_details.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Favourites',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: AnimatedBuilder(
        animation: FavoriteStore.instance,
        builder: (BuildContext context, _) {
          final List<FavoriteProduct> products = FavoriteStore.instance.items;

          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 54,
                    color: Color(0xFF98A1B3),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No favourite products yet',
                    style: TextStyle(color: Color(0xFF666E80)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              return _FavouriteCard(product: products[index]);
            },
          );
        },
      ),
    );
  }
}

class _FavouriteCard extends StatelessWidget {
  const _FavouriteCard({required this.product});

  final FavoriteProduct product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ScreenProductDetails(
              product: ProductDetailsData(
                id: product.id,
                name: product.name,
                image: product.image,
                description: product.description,
                brand: product.brand,
                price: product.price,
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 116,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x12000000), blurRadius: 14),
          ],
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 96,
                height: 96,
                child: _FavoriteImage(source: product.image),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF05A738),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove from favourites',
              onPressed: () => FavoriteStore.instance.remove(product.id),
              icon: const Icon(Icons.favorite, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteImage extends StatelessWidget {
  const _FavoriteImage({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final Uri? uri = Uri.tryParse(source);
    final bool network =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    const Widget fallback = ColoredBox(
      color: Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          Icons.medication_outlined,
          color: Color(0xFF0B83D9),
          size: 36,
        ),
      ),
    );

    return network
        ? Image.network(
            source,
            fit: BoxFit.cover,
            cacheWidth: 240,
            errorBuilder: (_, _, _) => fallback,
          )
        : Image.asset(
            source,
            fit: BoxFit.cover,
            cacheWidth: 240,
            errorBuilder: (_, _, _) => fallback,
          );
  }
}
