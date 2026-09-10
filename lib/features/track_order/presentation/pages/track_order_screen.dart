import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/track_order_entity.dart';
import '../bloc/track_order_bloc.dart';
import '../bloc/track_order_event.dart';
import '../bloc/track_order_state.dart';

const Color _blue = Color(0xff087cf0);
const Color _navy = Color(0xff223b8f);
const Color _ink = Color(0xff10142c);
const Color _muted = Color(0xff7183a5);
const Color _page = Color(0xfff5faff);

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key, this.initialCode});
  final String? initialCode;
  @override
  Widget build(BuildContext context) => BlocProvider<TrackOrderBloc>(
    create: (_) => sl<TrackOrderBloc>(),
    child: _TrackView(initialCode: initialCode),
  );
}

class _TrackView extends StatefulWidget {
  const _TrackView({this.initialCode});
  final String? initialCode;
  @override
  State<_TrackView> createState() => _TrackViewState();
}

class _TrackViewState extends State<_TrackView> {
  late final TextEditingController controller = TextEditingController(
    text: widget.initialCode ?? '',
  );
  @override
  void initState() {
    super.initState();
    if ((widget.initialCode ?? '').trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => submit());
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    FocusScope.of(context).unfocus();
    context.read<TrackOrderBloc>().add(
      TrackOrderSubmitted(code: controller.text),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _page,
    body: BlocBuilder<TrackOrderBloc, TrackOrderState>(
      builder: (context, state) => CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _Header(onBack: () => Navigator.of(context).maybePop()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            sliver: SliverList.list(
              children: <Widget>[
                _SearchCard(
                  controller: controller,
                  onSubmit: submit,
                  loading: state.status == TrackOrderStatus.loading,
                ),
                if (state.status == TrackOrderStatus.failure) ...<Widget>[
                  const SizedBox(height: 16),
                  _Message(
                    message:
                        state.failure?.message ?? 'Unable to find that order.',
                  ),
                ],
                if (state.hasOrder) ...<Widget>[
                  const SizedBox(height: 28),
                  const _DividerTitle(),
                  const SizedBox(height: 22),
                  _Result(order: state.order!),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 456,
    child: Stack(
      children: <Widget>[
        Container(
          height: 360,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xff49aafa), Color(0xffc4edff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(380, 96),
            ),
          ),
        ),
        Positioned(
          left: -70,
          right: -70,
          top: 285,
          child: Container(
            height: 210,
            decoration: BoxDecoration(
              color: _page.withValues(alpha: .9),
              borderRadius: const BorderRadius.vertical(
                top: Radius.elliptical(390, 110),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 14,
          left: 18,
          child: Material(
            color: Colors.white.withValues(alpha: .88),
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: _blue,
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 76,
          left: 0,
          right: 0,
          child: Column(
            children: <Widget>[
              Container(
                width: 92,
                height: 92,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x220b4f8f), blurRadius: 25),
                  ],
                ),
                child: Image.asset(
                  'assets/images/at_pharma_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Track Your Order',
                style: TextStyle(
                  color: _ink,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 34),
                child: Text(
                  'Enter your order ID or the phone number on the order to see live delivery updates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 17, height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.onSubmit,
    required this.loading,
  });
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool loading;
  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset.zero,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Order ID or phone number',
            style: TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: 'e.g. AT1000018 or 01712 345678',
              hintStyle: const TextStyle(color: Color(0xffa1aec5)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xffd7e0eb)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xffd7e0eb)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _blue, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton.icon(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              icon: loading
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search_rounded, size: 29),
              label: Text(
                loading ? 'Tracking...' : 'Track Order',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DividerTitle extends StatelessWidget {
  const _DividerTitle();
  @override
  Widget build(BuildContext context) => const Row(
    children: <Widget>[
      Expanded(child: Divider(color: Color(0xffccd8e7))),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Text(
          'Tracking Result',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
      ),
      Expanded(child: Divider(color: Color(0xffccd8e7))),
    ],
  );
}

class _Result extends StatelessWidget {
  const _Result({required this.order});
  final TrackOrderEntity order;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
    decoration: _card,
    child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const _IconBox(icon: Icons.inventory_2_outlined, purple: true),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Order ID',
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                  Text(
                    order.orderId.isEmpty
                        ? order.consignmentCode
                        : order.orderId,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (order.history.isNotEmpty &&
                      order.history.first.timestamp != null)
                    Text(
                      'Placed on ' + _date(order.history.first.timestamp!),
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                ],
              ),
            ),
            _Status(status: order.status),
          ],
        ),
        if (order.steps.isNotEmpty) ...<Widget>[
          const SizedBox(height: 28),
          _Progress(steps: order.steps),
        ],
        const SizedBox(height: 26),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xfff1f7ff),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: <Widget>[
              const _IconBox(icon: Icons.calendar_month_outlined),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Latest update',
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                    Text(
                      order.history.isEmpty
                          ? order.status
                          : order.history.last.title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!order.address.isEmpty) ...<Widget>[
          const SizedBox(height: 18),
          _SmallDetail(
            icon: Icons.location_on_outlined,
            title: 'Delivery address',
            value: order.address.address,
          ),
        ],
        if (!order.rider.isEmpty) ...<Widget>[
          const SizedBox(height: 12),
          _SmallDetail(
            icon: Icons.delivery_dining_outlined,
            title: 'Delivery rider',
            value:
                order.rider.name +
                (order.rider.phone.isEmpty ? '' : ' · ' + order.rider.phone),
          ),
        ],
      ],
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.steps});
  final List<TrackOrderStepEntity> steps;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List<Widget>.generate(steps.length, (int i) {
      final TrackOrderStepEntity step = steps[i];
      return Expanded(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 3,
                    color: i == 0
                        ? Colors.transparent
                        : (step.isCompleted ? _blue : const Color(0xffd4dfed)),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted ? _blue : Colors.white,
                    border: Border.all(
                      color: step.isCompleted ? _blue : const Color(0xffcbd7e6),
                      width: 2,
                    ),
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 19)
                      : const Icon(
                          Icons.circle,
                          color: Color(0xffdbe5f1),
                          size: 13,
                        ),
                ),
                Expanded(
                  child: Container(
                    height: 3,
                    color: i == steps.length - 1
                        ? Colors.transparent
                        : (steps[i + 1].isCompleted
                              ? _blue
                              : const Color(0xffd4dfed)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              step.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: _ink,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }),
  );
}

class _Status extends StatelessWidget {
  const _Status({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xffdcf8e9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(
          Icons.local_shipping_outlined,
          color: Color(0xff08a668),
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          status,
          style: const TextStyle(
            color: Color(0xff08a668),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, this.purple = false});
  final IconData icon;
  final bool purple;
  @override
  Widget build(BuildContext context) {
    final Color color = purple ? const Color(0xff4e5cf5) : _blue;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

class _SmallDetail extends StatelessWidget {
  const _SmallDetail({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Icon(icon, color: _blue, size: 21),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: const TextStyle(color: _muted, fontSize: 12)),
            Text(
              value,
              style: const TextStyle(color: _ink, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _card,
    child: Row(
      children: <Widget>[
        const Icon(Icons.error_outline, color: Colors.redAccent),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

String _date(DateTime value) {
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
  return value.day.toString() +
      ' ' +
      months[value.month - 1] +
      ' ' +
      value.year.toString();
}

final BoxDecoration _card = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  boxShadow: const <BoxShadow>[
    BoxShadow(color: Color(0x120d4d83), blurRadius: 28, offset: Offset(0, 10)),
  ],
);
