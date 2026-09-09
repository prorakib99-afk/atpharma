import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/track_order_entity.dart';
import '../bloc/track_order_bloc.dart';
import '../bloc/track_order_event.dart';
import '../bloc/track_order_state.dart';

const Color _kPrimary = Color(0xff1e2a5e);
const Color _kMuted = Color(0xff6b7280);
const Color _kBorder = Color(0xffe5e7eb);
const Color _kBackground = Color(0xfff5f6fa);
const Color _kSuccess = Color(0xff16a34a);

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrackOrderBloc>(
      create: (_) => sl<TrackOrderBloc>(),
      child: _TrackOrderView(initialCode: initialCode),
    );
  }
}

class _TrackOrderView extends StatefulWidget {
  const _TrackOrderView({this.initialCode});

  final String? initialCode;

  @override
  State<_TrackOrderView> createState() => _TrackOrderViewState();
}

class _TrackOrderViewState extends State<_TrackOrderView> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialCode ?? '',
  );

  @override
  void initState() {
    super.initState();

    final String? code = widget.initialCode?.trim();

    if (code != null && code.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _submit());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<TrackOrderBloc>().add(
      TrackOrderSubmitted(code: _controller.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SearchCard(controller: _controller, onSubmit: _submit),
                    const SizedBox(height: 16),
                    BlocBuilder<TrackOrderBloc, TrackOrderState>(
                      builder: (context, state) {
                        if (state.status == TrackOrderStatus.loading) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 48),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (state.status == TrackOrderStatus.failure) {
                          return _ErrorCard(
                            message:
                                state.failure?.message ??
                                'Unable to find that order.',
                          );
                        }

                        if (state.hasOrder) {
                          return _TrackOrderResult(order: state.order!);
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: _kPrimary),
          ),
          const Text(
            'Track Your Order',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _kPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order ID or phone number',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xff374151),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: 'e.g. AT1000023',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _kPrimary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.search, size: 18),
              label: const Text(
                'Track Order',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xff374151)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackOrderResult extends StatelessWidget {
  const _TrackOrderResult({required this.order});

  final TrackOrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusCard(order: order),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 480;
            final List<Widget> panels = <Widget>[
              _AddressCard(order: order),
              _RiderCard(order: order),
            ];

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  panels[0],
                  const SizedBox(height: 14),
                  panels[1],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: panels[0]),
                const SizedBox(width: 14),
                Expanded(child: panels[1]),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        if (order.items.isNotEmpty) _ItemsCard(order: order),
        if (order.items.isNotEmpty) const SizedBox(height: 14),
        if (order.history.isNotEmpty) _HistoryCard(order: order),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});

  final TrackOrderEntity order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER ${order.orderId}',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w700,
                        color: _kMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Consignment ${order.consignmentCode}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (order.status.isNotEmpty) _StatusBadge(status: order.status),
            ],
          ),
          if (order.steps.isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            _StepperRow(steps: order.steps),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xffdcfce7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: _kSuccess,
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({required this.steps});

  final List<TrackOrderStepEntity> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(steps.length, (int index) {
        final TrackOrderStepEntity step = steps[index];
        final bool isLast = index == steps.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 0
                          ? Colors.transparent
                          : (step.isCompleted ? _kPrimary : _kBorder),
                    ),
                  ),
                  _StepDot(isCompleted: step.isCompleted),
                  if (isLast)
                    const Expanded(child: SizedBox.shrink())
                  else
                    Expanded(
                      child: Container(
                        height: 2,
                        color: steps[index + 1].isCompleted
                            ? _kPrimary
                            : _kBorder,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                step.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: step.isCompleted ? _kPrimary : _kMuted,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCompleted ? _kPrimary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted ? _kPrimary : _kBorder,
          width: 1.5,
        ),
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.order});

  final TrackOrderEntity order;

  @override
  Widget build(BuildContext context) {
    if (order.address.isEmpty) {
      return const SizedBox.shrink();
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeading(
            icon: Icons.location_on_outlined,
            title: 'Delivery address',
          ),
          const SizedBox(height: 8),
          if (order.address.name.isNotEmpty)
            Text(
              order.address.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          if (order.address.phone.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              order.address.phone,
              style: const TextStyle(fontSize: 12, color: _kMuted),
            ),
          ],
          if (order.address.address.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              order.address.address,
              style: const TextStyle(fontSize: 12, color: _kMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _RiderCard extends StatelessWidget {
  const _RiderCard({required this.order});

  final TrackOrderEntity order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeading(
            icon: Icons.person_outline,
            title: 'Delivery rider',
          ),
          const SizedBox(height: 8),
          if (order.rider.name.isNotEmpty)
            Text(
              order.rider.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          if (order.rider.phone.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              order.rider.phone,
              style: const TextStyle(fontSize: 12, color: _kMuted),
            ),
          ],
          if (order.rider.isEmpty)
            const Text(
              "A rider hasn't been assigned yet.",
              style: TextStyle(fontSize: 12, color: _kMuted),
            ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final TrackOrderEntity order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            icon: Icons.inventory_2_outlined,
            title: 'Items (${order.items.length})',
          ),
          const SizedBox(height: 10),
          for (final TrackOrderItemEntity item in order.items) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatCurrency(item.unitPrice)} × ${item.quantity}',
                        style: const TextStyle(fontSize: 11.5, color: _kMuted),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(item.total),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          const Divider(height: 1, color: _kBorder),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.deliveryFee <= 0 ? 'Delivery (free)' : 'Delivery',
                style: const TextStyle(fontSize: 12, color: _kMuted),
              ),
              Text(
                _formatCurrency(order.total),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.order});

  final TrackOrderEntity order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeading(
            icon: Icons.local_shipping_outlined,
            title: 'Tracking history',
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < order.history.length; i++)
            _HistoryTile(
              entry: order.history[i],
              isLast: i == order.history.length - 1,
            ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.isLast});

  final TrackOrderHistoryEntryEntity entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: _kPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: _kBorder)),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  if (entry.description.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      entry.description,
                      style: const TextStyle(fontSize: 11.5, color: _kMuted),
                    ),
                  ],
                  if (entry.timestamp != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(entry.timestamp!),
                      style: const TextStyle(fontSize: 10.5, color: _kMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _kPrimary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}

String _formatCurrency(double value) {
  return '৳${value.toStringAsFixed(2)}';
}

String _formatTimestamp(DateTime timestamp) {
  const List<String> months = <String>[
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

  final int hour24 = timestamp.hour;
  final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final String period = hour24 < 12 ? 'AM' : 'PM';
  final String minute = timestamp.minute.toString().padLeft(2, '0');

  return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year} • '
      '$hour12:$minute $period';
}
