import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// DATA MODEL
/// ---------------------------------------------------------------------
class NotifEntry {
  final String title;
  final String subtitle;
  final String timeAgo;
  bool isRead;

  NotifEntry({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.isRead = false,
  });
}

/// ---------------------------------------------------------------------
/// NOTIFICATION SCREEN — compact dropdown-style notification list.
/// ---------------------------------------------------------------------
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    super.key,
    this.entries,
    this.maxHeight = 320,
    this.width = 320,
  });

  final List<NotifEntry>? entries;
  final double maxHeight;
  final double width;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<NotifEntry> _entries;
  final _scrollController = ScrollController();

  static const _primary = Color(0xff0b83d9);
  static const _primarySoft = Color(0xffe7f3fb);
  static const _textDark = Color(0xff131314);
  static const _textMuted = Color(0xff6b7280);

  @override
  void initState() {
    super.initState();
    _entries =
        widget.entries ??
        [
          NotifEntry(
            title: 'New order AT1000030',
            subtitle: 'azizul hakim placed an order for SAR 64.16 (4 item...',
            timeAgo: '2d ago',
          ),
          NotifEntry(
            title: 'Payment received \u00b7 AT1000029',
            subtitle: 'Card payment for order AT1000029 was complete...',
            timeAgo: '4d ago',
          ),
          NotifEntry(
            title: 'New order AT1000029',
            subtitle: 'TANZIM Al Tamam placed an order for SAR 52.56 (...',
            timeAgo: '5d ago',
          ),
          NotifEntry(
            title: 'New order AT1000028',
            subtitle: 'TANZIM Al Tamam placed an order for SAR 52.56 (...',
            timeAgo: '5d ago',
          ),
          NotifEntry(
            title: 'Payment received \u00b7 AT1000027',
            subtitle: 'Card payment for order AT1000027 was complete...',
            timeAgo: '6d ago',
          ),
        ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _unreadCount => _entries.where((e) => !e.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final e in _entries) {
        e.isRead = true;
      }
    });
  }

  void _scrollBy(double delta) {
    final target = (_scrollController.offset + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
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
            constraints: BoxConstraints(maxHeight: widget.maxHeight + 52),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffe5e7eb)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(unreadCount: _unreadCount, onMarkAllRead: _markAllRead),
                Flexible(
                  child: _entries.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: Text(
                              'No notifications',
                              style: TextStyle(color: Color(0xff9aa1ab)),
                            ),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ListView.separated(
                                controller: _scrollController,
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                itemCount: _entries.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: Colors.grey.shade200,
                                ),
                                itemBuilder: (context, i) => _NotifTile(
                                  entry: _entries[i],
                                  onTap: () =>
                                      setState(() => _entries[i].isRead = true),
                                ),
                              ),
                            ),
                            _MiniScrollbar(
                              onUp: () => _scrollBy(-60),
                              onDown: () => _scrollBy(60),
                            ),
                          ],
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
/// HEADER
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({required this.unreadCount, required this.onMarkAllRead});
  final int unreadCount;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Row(
        children: [
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 8),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xffe7f3fb),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unreadCount new',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff0b83d9),
                ),
              ),
            ),
          const Spacer(),
          InkWell(
            onTap: onMarkAllRead,
            borderRadius: BorderRadius.circular(6),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.done_all, size: 14, color: Color(0xff0b83d9)),
                SizedBox(width: 4),
                Text(
                  'Mark all read',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff0b83d9),
                  ),
                ),
              ],
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
  const _NotifTile({required this.entry, required this.onTap});
  final NotifEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: entry.isRead ? Colors.transparent : const Color(0xfff7fbff),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: SizedBox(
                width: 14,
                child: entry.isRead
                    ? null
                    : Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xff0b83d9),
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xff6b7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.timeAgo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff9aa1ab),
                    ),
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

/// ---------------------------------------------------------------------
/// MINI SCROLLBAR (up/down arrow buttons, matches the reference design)
/// ---------------------------------------------------------------------
class _MiniScrollbar extends StatelessWidget {
  const _MiniScrollbar({required this.onUp, required this.onDown});
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onUp,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(
                Icons.arrow_drop_up,
                size: 18,
                color: Color(0xff9aa1ab),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onDown,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: Color(0xff9aa1ab),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
