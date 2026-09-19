import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// DATA MODEL
/// ---------------------------------------------------------------------
enum NotifType { order, payment, prescription, general }

class NotifEntry {
  final String title;
  final String subtitle;
  final String timeAgo;
  final NotifType type;
  bool isRead;

  NotifEntry({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.type = NotifType.general,
    this.isRead = false,
  });
}

/// ---------------------------------------------------------------------
/// NOTIFICATION SCREEN — floating notification panel.
/// ---------------------------------------------------------------------
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    super.key,
    this.entries,
    this.maxHeight = 360,
    this.width = 320,
    this.onOpenNotificationCenter,
  });

  final List<NotifEntry>? entries;
  final double maxHeight;
  final double width;
  final VoidCallback? onOpenNotificationCenter;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<NotifEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries =
        widget.entries ??
        [
          NotifEntry(
            title: 'Order AT1000030 confirmed',
            subtitle: 'SAR 64.50 · Cash on delivery',
            timeAgo: 'Just now',
            type: NotifType.order,
          ),
          NotifEntry(
            title: 'Payment received',
            subtitle: 'AT1000029 payment was successful',
            timeAgo: '4m ago',
            type: NotifType.payment,
          ),
          NotifEntry(
            title: 'Prescription approved',
            subtitle: 'Your uploaded prescription was reviewed',
            timeAgo: '18m ago',
            type: NotifType.prescription,
          ),
        ];
  }

  int get _unreadCount => _entries.where((e) => !e.isRead).length;

  void _clearAll() {
    setState(() => _entries.clear());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth < widget.width
                  ? constraints.maxWidth
                  : widget.width)
            : widget.width;

        return Material(
          color: Colors.transparent,
          child: Container(
            width: effectiveWidth,
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(unreadCount: _unreadCount, onClearAll: _clearAll),
                Flexible(
                  child: _entries.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Text(
                              'No notifications',
                              style: TextStyle(color: Color(0xff9aa1ab)),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                          itemCount: _entries.length,
                          itemBuilder: (context, i) => _NotifTile(
                            entry: _entries[i],
                            onTap: () =>
                                setState(() => _entries[i].isRead = true),
                            onMarkAsRead: () =>
                                setState(() => _entries[i].isRead = true),
                          ),
                        ),
                ),
                InkWell(
                  onTap: widget.onOpenNotificationCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xffeef0f2)),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Open notification center',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff0b83d9),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// HEADER — blue gradient banner
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({required this.unreadCount, required this.onClearAll});
  final int unreadCount;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1591e8), Color(0xff0b6fc4)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount > 0
                      ? 'You have $unreadCount unread updates'
                      : 'You’re all caught up',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xffdcedfb),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onClearAll,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// SINGLE NOTIFICATION ROW
/// ---------------------------------------------------------------------
class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.entry,
    required this.onTap,
    required this.onMarkAsRead,
  });
  final NotifEntry entry;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  ({IconData icon, Color color, Color bg}) get _style {
    switch (entry.type) {
      case NotifType.order:
        return (
          icon: Icons.description_rounded,
          color: const Color(0xff0b83d9),
          bg: const Color(0xffe7f3fb),
        );
      case NotifType.payment:
        return (
          icon: Icons.attach_money_rounded,
          color: const Color(0xff17a45a),
          bg: const Color(0xffe4f7ec),
        );
      case NotifType.prescription:
        return (
          icon: Icons.receipt_long_rounded,
          color: const Color(0xff7c5cf0),
          bg: const Color(0xffede8fd),
        );
      case NotifType.general:
        return (
          icon: Icons.notifications_rounded,
          color: const Color(0xff9aa1ab),
          bg: const Color(0xfff0f1f3),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: entry.isRead ? const Color(0xfff8f9fb) : const Color(0xfff1f8fe),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(style.icon, size: 20, color: style.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff131314),
                          ),
                        ),
                      ),
                      if (!entry.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff0b83d9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff6b7280),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        entry.timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xff9aa1ab),
                        ),
                      ),
                      if (!entry.isRead) ...[
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: onMarkAsRead,
                          child: const Text(
                            'Mark as Read',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff0b83d9),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
