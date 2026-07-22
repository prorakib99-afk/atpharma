import 'package:flutter/material.dart';

import '../../../../shared/widgets/navigation_page_scaffold.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final List<String> _recent = ['Paracetamol', 'Vitamin D3', 'Hand Sanitizer'];
  String _query = '';
  bool _submitted = false;
  int _page = 0;

  List<String> get _suggestions {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final values = _searchTerms
        .where((item) => item.toLowerCase().contains(query))
        .toList();
    values.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return values;
  }

  List<_Product> get _results {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return _products.where((product) {
      final text = '${product.name} ${product.tags}'.toLowerCase();
      return text.contains(query) ||
          query
              .split(' ')
              .any((word) => word.length > 2 && text.contains(word));
    }).toList();
  }

  void _search([String? value]) {
    final query = (value ?? _controller.text).trim();
    if (query.isEmpty) return;
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    setState(() {
      _query = query;
      _submitted = true;
      _page = 0;
      _recent.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
      _recent.insert(0, query);
    });
    _focusNode.unfocus();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _query = '';
      _submitted = false;
      _page = 0;
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NavigationPageScaffold(
    currentPage: NavigationPage.search,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _Header(),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  sliver: SliverToBoxAdapter(child: _content()),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: _SearchField(
              controller: _controller,
              focusNode: _focusNode,
              submitted: _submitted,
              onChanged: (value) => setState(() {
                _query = value;
                _submitted = false;
              }),
              onSubmitted: _search,
              onClear: _clearSearch,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _content() {
    if (_submitted)
      return _results.isEmpty
          ? _NoResults(query: _query, onSuggestion: _search)
          : _Results(
              query: _query,
              results: _results,
              page: _page,
              onPageChanged: (page) => setState(() => _page = page),
            );
    if (_query.trim().isNotEmpty)
      return _SuggestionState(
        query: _query,
        suggestions: _suggestions,
        onSelected: _search,
      );
    return _DefaultState(
      recent: _recent,
      onPopular: _search,
      onRecent: _search,
      onRemoveRecent: (value) => setState(() => _recent.remove(value)),
      onClearRecent: () => setState(_recent.clear),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search',
              style: TextStyle(
                fontSize: 18,
                height: 22 / 18,
                fontWeight: FontWeight.w600,
                color: _Colors.text,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Find medicines & daily essentials.',
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                color: _Colors.body,
              ),
            ),
          ],
        ),
      ),
      const _RoundIcon(Icons.notifications_none_rounded),
      const SizedBox(width: 4),
      const _RoundIcon(Icons.favorite_border_rounded),
      const SizedBox(width: 4),
      ClipOval(
        child: Image.asset(
          'assets/images/at_pharma_icon.png',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          cacheWidth: 80,
        ),
      ),
    ],
  );
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 28)],
    ),
    child: Icon(icon, size: 20),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.submitted,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool submitted;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Search by product name, brands...',
      hintStyle: const TextStyle(fontSize: 12, color: _Colors.placeholder),
      prefixIcon: Icon(
        submitted ? Icons.chevron_left_rounded : Icons.search_rounded,
        color: _Colors.text,
      ),
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.cancel_outlined, color: _Colors.body),
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _Colors.border, width: .8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _Colors.blue, width: 1.5),
      ),
    ),
  );
}

class _DefaultState extends StatelessWidget {
  const _DefaultState({
    required this.recent,
    required this.onPopular,
    required this.onRecent,
    required this.onRemoveRecent,
    required this.onClearRecent,
  });
  final List<String> recent;
  final ValueChanged<String> onPopular;
  final ValueChanged<String> onRecent;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Popular Searches', style: _Text.section),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Fever', 'Diabetes', 'Skin Care', 'Baby Care']
                  .map(
                    (item) => ActionChip(
                      onPressed: () => onPopular(item),
                      label: Text(item),
                      labelStyle: const TextStyle(color: _Colors.blue),
                      backgroundColor: _Colors.lightBlue,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suggested for you', style: _Text.section),
            const SizedBox(height: 16),
            ..._products
                .take(4)
                .map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HorizontalCard(product),
                  ),
                ),
          ],
        ),
      ),
      if (recent.isNotEmpty) ...[
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Recent searches', style: _Text.section),
                  ),
                  TextButton(
                    onPressed: onClearRecent,
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...recent.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => onRecent(item),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _Colors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          IconButton(
                            onPressed: () => onRemoveRecent(item),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: _Colors.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

class _SuggestionState extends StatelessWidget {
  const _SuggestionState({
    required this.query,
    required this.suggestions,
    required this.onSelected,
  });
  final String query;
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Match', style: _Text.section),
            const SizedBox(height: 16),
            _SuggestionTile(
              title: query,
              leading: Icons.schedule_rounded,
              onTap: () => onSelected(query),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suggestions', style: _Text.section),
            const SizedBox(height: 4),
            const Text(
              'Search by medicine, brand or symptom',
              style: TextStyle(fontSize: 12, color: _Colors.body),
            ),
            const SizedBox(height: 16),
            if (suggestions.isEmpty)
              const Text(
                'No matching suggestions',
                style: TextStyle(fontSize: 12, color: _Colors.body),
              ),
            ...suggestions
                .take(6)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SuggestionTile(
                      title: item,
                      onTap: () => onSelected(item),
                    ),
                  ),
                ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      ListTile(
        onTap: () => onSelected(query),
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(
          'View all results for “$query”',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.title,
    required this.onTap,
    this.leading = Icons.search_rounded,
  });
  final String title;
  final VoidCallback onTap;
  final IconData leading;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.border),
      ),
      child: Row(
        children: [
          Icon(leading, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Medicine · 24 products',
                  style: TextStyle(fontSize: 12, color: _Colors.body),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}

class _Results extends StatelessWidget {
  const _Results({
    required this.query,
    required this.results,
    required this.page,
    required this.onPageChanged,
  });
  final String query;
  final List<_Product> results;
  final int page;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    const pageSize = 6;
    final pageCount = (results.length / pageSize).ceil();
    final visible = results.skip(page * pageSize).take(pageSize).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${results.length} results for “$query”', style: _Text.section),
        const SizedBox(height: 4),
        const Text(
          'Medicine, syrup & fever relief',
          style: TextStyle(fontSize: 12, color: _Colors.body),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          itemCount: visible.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 270,
          ),
          itemBuilder: (_, index) => _GridCard(visible[index]),
        ),
        if (pageCount > 1) ...[
          const SizedBox(height: 24),
          _Pagination(page: page, count: pageCount, onChanged: onPageChanged),
        ],
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.onSuggestion});
  final String query;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 150,
        height: 150,
        decoration: const BoxDecoration(
          color: _Colors.lightBlue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.manage_search_rounded,
          size: 88,
          color: _Colors.blue,
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'No exact results found',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Text(
        'We couldn’t find “$query”.\nCheck the spelling or try a different name.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: _Colors.body),
      ),
      const SizedBox(height: 24),
      InkWell(
        onTap: () => onSuggestion('Paracetamol 500mg'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 274,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: _Colors.lightBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _Colors.blue),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Did you mean?', style: TextStyle(fontSize: 12)),
                    SizedBox(height: 4),
                    Text(
                      'Paracetamol 500mg',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
      const SizedBox(height: 28),
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Popular alternatives', style: _Text.section),
            const SizedBox(height: 16),
            ..._products
                .take(3)
                .map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HorizontalCard(product),
                  ),
                ),
          ],
        ),
      ),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _Colors.card,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

class _HorizontalCard extends StatelessWidget {
  const _HorizontalCard(this.product);
  final _Product product;
  @override
  Widget build(BuildContext context) => Container(
    height: 116,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: _Colors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 12)],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            product.image,
            width: 104,
            height: 100,
            fit: BoxFit.cover,
            cacheWidth: 208,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FreshLife',
                style: TextStyle(
                  fontSize: 10,
                  color: _Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (product.rx) const _RxBadge(),
                ],
              ),
              const Text(
                'Pure natural honey.',
                style: TextStyle(fontSize: 10, color: _Colors.body),
              ),
              const Spacer(),
              const Divider(height: 1, color: _Colors.border),
              const SizedBox(height: 5),
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      '82 in stock',
                      style: TextStyle(fontSize: 10, color: _Colors.blue),
                    ),
                  ),
                  Text(
                    '৳500',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 12),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _Colors.blue,
                    child: Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GridCard extends StatelessWidget {
  const _GridCard(this.product);
  final _Product product;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: _Colors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 14)],
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
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                    cacheWidth: 320,
                  ),
                ),
              ),
              const Positioned(
                right: -1,
                bottom: -14,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: _Colors.blue,
                  child: Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'FreshLife',
          style: TextStyle(
            fontSize: 10,
            color: _Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (product.rx) const _RxBadge(),
          ],
        ),
        const Text(
          'Pure natural honey.',
          maxLines: 1,
          style: TextStyle(fontSize: 10, color: _Colors.body),
        ),
        const Spacer(),
        const Divider(height: 1, color: _Colors.border),
        const SizedBox(height: 6),
        const Row(
          children: [
            Expanded(
              child: Text(
                '82 in stock',
                style: TextStyle(fontSize: 10, color: _Colors.blue),
              ),
            ),
            Text(
              '৳500',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    ),
  );
}

class _RxBadge extends StatelessWidget {
  const _RxBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
    decoration: BoxDecoration(
      color: const Color(0xFFE71C05),
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Text(
      'Rx',
      style: TextStyle(fontSize: 10, color: Colors.white),
    ),
  );
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.count,
    required this.onChanged,
  });
  final int page;
  final int count;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      ...List.generate(
        count,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => onChanged(index),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: index == page ? _Colors.blue : _Colors.card,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: index == page ? Colors.white : _Colors.text,
                ),
              ),
            ),
          ),
        ),
      ),
      const Spacer(),
      IconButton(
        onPressed: page > 0 ? () => onChanged(page - 1) : null,
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      IconButton(
        onPressed: page + 1 < count ? () => onChanged(page + 1) : null,
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class _Product {
  const _Product(this.name, this.image, this.tags, {this.rx = false});
  final String name;
  final String image;
  final String tags;
  final bool rx;
}

const _products = [
  _Product(
    'Paracetamol 500mg',
    'assets/images/product_5_opt.jpg',
    'paracetamol fever medicine pain',
    rx: true,
  ),
  _Product(
    'Cefixime 200mg',
    'assets/images/product_6_opt.jpg',
    'cefixime antibiotic medicine',
  ),
  _Product(
    'Metformin 500mg',
    'assets/images/product_7_opt.jpg',
    'metformin diabetes medicine',
    rx: true,
  ),
  _Product(
    'Vitamin D3 60K',
    'assets/images/product_4_opt.jpg',
    'vitamin supplement medicine',
  ),
  _Product(
    'Organic Honey 500g',
    'assets/images/product_1_opt.jpg',
    'honey grocery fever',
  ),
  _Product(
    'Hand Sanitizer Gel',
    'assets/images/product_2_opt.jpg',
    'sanitizer skin care personal care',
  ),
  _Product(
    'ORS Oral Saline Sachet',
    'assets/images/product_3_opt.jpg',
    'ors saline fever dehydration medicine',
  ),
];

const _searchTerms = [
  'Baby Care',
  'Cefixime 200mg',
  'Diabetes Care',
  'Fever medicine',
  'Hand Sanitizer',
  'Metformin 500mg',
  'Napa Extra 500mg',
  'Organic Honey',
  'ORS Oral Saline',
  'Paracetamol 500mg',
  'Paracetamol for fever',
  'Paracetamol syrup',
  'Personal Care',
  'Skin Care',
  'Vitamin D3 60K',
];

class _Colors {
  static const blue = Color(0xFF0B83D9);
  static const lightBlue = Color(0xFFE7F3FB);
  static const text = Color(0xFF131415);
  static const body = Color(0xFF666E80);
  static const placeholder = Color(0xFF98A1B3);
  static const border = Color(0xFFE1E2E6);
  static const card = Color(0xFFF7F8FA);
  static const green = Color(0xFF05972C);
}

class _Text {
  static const section = TextStyle(
    fontSize: 14,
    height: 24 / 14,
    fontWeight: FontWeight.w600,
    color: _Colors.text,
  );
}
