import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/shop_order_entity.dart';
import '../bloc/shop_orders_bloc.dart';
import '../bloc/shop_orders_event.dart';
import '../bloc/shop_orders_state.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider<ShopOrdersBloc>(
    create: (_) => sl<ShopOrdersBloc>()..add(const ShopOrdersRequested()),
    child: const _View(),
  );
}

class _View extends StatefulWidget {
  const _View();
  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  int filter = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6faff),
      body: BlocBuilder<ShopOrdersBloc, ShopOrdersState>(
        builder: (context, state) {
          final all = state.orders;
          final orders = filter == 0
              ? all
              : all
                    .where((o) => filter == 1 ? o.isOngoing : o.isDelivered)
                    .toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ShopOrdersBloc>().add(
                const ShopOrdersRequested(refresh: true),
              );
              await context.read<ShopOrdersBloc>().stream.firstWhere(
                (s) => s.status != ShopOrdersStatus.loading,
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
                      _Summary(
                        total: all.length,
                        ongoing: all.where((o) => o.isOngoing).length,
                        delivered: all.where((o) => o.isDelivered).length,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'My order history',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff0f1530),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Tabs(
                        value: filter,
                        onChanged: (v) => setState(() => filter = v),
                      ),
                      const SizedBox(height: 20),
                      if (state.status == ShopOrdersStatus.loading &&
                          all.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state.status == ShopOrdersStatus.failure &&
                          all.isEmpty)
                        _Error(
                          message:
                              state.failure?.message ?? 'Could not load orders',
                          retry: () => context.read<ShopOrdersBloc>().add(
                            const ShopOrdersRequested(),
                          ),
                        )
                      else if (orders.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text('No orders found'),
                          ),
                        )
                      else
                        for (final order in orders) ...<Widget>[
                          _OrderCard(order: order),
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
    height: 302,
    child: Stack(
      children: [
        Container(
          height: 290,
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
          top: 112,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x240c4f8e),
                      blurRadius: 18,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/at_pharma_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'My Orders',
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff0f1530),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track, review and manage your orders in one\nplace.',
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

class _Summary extends StatelessWidget {
  const _Summary({
    required this.total,
    required this.ongoing,
    required this.delivered,
  });
  final int total, ongoing, delivered;
  @override
  Widget build(BuildContext context) => Container(
    height: 92,
    padding: const EdgeInsets.all(15),
    decoration: _dec,
    child: Row(
      children: [
        const _Icon(),
        const SizedBox(width: 12),
        Expanded(child: _Stat('Total Orders', total)),
        const VerticalDivider(),
        Expanded(child: _Stat('Ongoing', ongoing)),
        const VerticalDivider(),
        Expanded(child: _Stat('Delivered', delivered)),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final int value;
  @override
  Widget build(BuildContext c) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xff7283a1), fontSize: 12),
      ),
      Text(
        value.toString(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xff0f1530),
        ),
      ),
    ],
  );
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext c) => Container(
    height: 48,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xffe4ebf4)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: InkWell(
            onTap: () => onChanged(i),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: value == i
                    ? const Color(0xff263a8b)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                const ['All', 'Ongoing', 'Delivered'][i],
                style: TextStyle(
                  color: value == i ? Colors.white : const Color(0xff6f809d),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final ShopOrderEntity order;
  @override
  Widget build(BuildContext context) {
    final color = order.isDelivered
        ? const Color(0xff14945f)
        : order.status.toLowerCase().contains('cancel')
        ? const Color(0xffe04454)
        : const Color(0xff0aa66a);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _dec,
      child: Column(
        children: [
          Row(
            children: [
              const _Icon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff0f1530),
                      ),
                    ),
                    Text(
                      'Placed on ${_date(order.createdAt)}',
                      style: const TextStyle(
                        color: Color(0xff7283a1),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 25, color: Color(0xffe4ebf4)),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${order.itemCount} items   •   SAR ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xff667a9b),
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(
                height: 38,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.trackOrder,
                    arguments: order.orderNumber,
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: order.isOngoing
                        ? const Color(0xff263a8b)
                        : const Color(0xfff4f7fc),
                    foregroundColor: order.isOngoing
                        ? Colors.white
                        : const Color(0xff263a8b),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(order.isOngoing ? 'Track Order' : 'View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon();
  @override
  Widget build(BuildContext c) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: const Color(0xffeef2ff),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.inventory_2_outlined, color: Color(0xff2264f5)),
  );
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext c) => Column(
    children: [
      Text(message),
      TextButton(onPressed: retry, child: const Text('Try again')),
    ],
  );
}

String _date(DateTime? d) {
  if (d == null) return 'Not available';
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

final _dec = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xffe7edf6)),
  borderRadius: BorderRadius.circular(20),
  boxShadow: const [
    BoxShadow(color: Color(0x1a263b8c), blurRadius: 24, offset: Offset(0, 8)),
  ],
);
