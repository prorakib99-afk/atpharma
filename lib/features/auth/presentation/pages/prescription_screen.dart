import 'package:flutter/material.dart';

import '../../../../shared/widgets/navigation_page_scaffold.dart';
import 'favorite_store.dart';
import 'favourite_screen.dart';

/// AI Prescription Assistant upload screen.
///
/// Layout: scrollable info section (badge, title, subtitle, disclaimer,
/// empty-state card) on top, with a chat-style input bar pinned to the
/// bottom (paperclip attach + text field + send button) — the input bar
/// never scrolls away, matching common chat/assistant UI patterns.
class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key, this.onAttachTap, this.onSendMessage});

  final VoidCallback? onAttachTap;
  final ValueChanged<String>? onSendMessage;

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _messageController = TextEditingController();

  static const _textDark = Color(0xff14181f);
  static const _textMuted = Color(0xff6b7280);

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage?.call(text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationPageScaffold(
      currentPage: NavigationPage.prescription,
      backgroundColor: Colors.white,
      extendBody: false,
      appBar: const _PrescriptionAppBar(),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width >= 600;
            final contentMaxWidth = isTablet ? 640.0 : double.infinity;
            final horizontalPadding = width <= 340 ? 16.0 : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        8,
                        horizontalPadding,
                        6,
                      ),
                      child: const _AssistantBadge(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          12,
                          horizontalPadding,
                          16,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Upload your prescription',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        'Upload a photo or PDF of your prescription and I\u2019ll find the matching medicines from ',
                                  ),
                                  TextSpan(
                                    text: 'AT PHARMA',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _textMuted,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '. Add what you need to your cart and check out.',
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.5,
                                color: _textMuted,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const _DisclaimerBanner(),
                            const SizedBox(height: 20),
                            const _EmptyStateCard(),
                          ],
                        ),
                      ),
                    ),
                    _ChatInputBar(
                      controller: _messageController,
                      onAttachTap: widget.onAttachTap,
                      onSend: _send,
                      horizontalPadding: horizontalPadding,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PrescriptionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _PrescriptionAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.sizeOf(context).width <= 340
        ? 16
        : 20;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      toolbarHeight: preferredSize.height,
      titleSpacing: horizontalPadding,
      title: const _PrescriptionHeader(),
    );
  }
}

class _PrescriptionHeader extends StatelessWidget {
  const _PrescriptionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Text(
            'Prescription',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF131415),
            ),
          ),
        ),
        const _HeaderIcon(icon: Icons.notifications_none_rounded),
        const SizedBox(width: 6),
        const _FavouriteHeaderIcon(),
        const SizedBox(width: 6),
        const _ProfileAvatar(),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(color: Color(0x14000000), blurRadius: 18),
          ],
        ),
        child: Icon(icon, size: 20, color: Color(0xFF131415)),
      ),
    );
  }
}

class _FavouriteHeaderIcon extends StatelessWidget {
  const _FavouriteHeaderIcon();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoriteStore.instance,
      builder: (BuildContext context, _) {
        final int count = FavoriteStore.instance.count;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            _HeaderIcon(
              icon: count > 0
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FavouriteScreen(),
                  ),
                );
              },
            ),
            if (count > 0)
              Positioned(
                right: -2,
                top: -3,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17),
                  height: 17,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE71B05),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/images/at_pharma_icon.png',
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        cacheWidth: 80,
        errorBuilder: (_, _, _) {
          return const SizedBox(
            width: 40,
            height: 40,
            child: ColoredBox(
              color: Color(0xFFE7F3FB),
              child: Icon(Icons.person_rounded, color: Color(0xFF0B83D9)),
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// TOP BADGE PILL
/// ---------------------------------------------------------------------
class _AssistantBadge extends StatelessWidget {
  const _AssistantBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffe9f1ff),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 15, color: Color(0xff2f6fed)),
          SizedBox(width: 6),
          Text(
            'AI Prescription Assistant',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff2f6fed),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// DISCLAIMER BANNER
/// ---------------------------------------------------------------------
class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfffdf3e2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xfff3e2b8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 18, color: Color(0xff8a6d1f)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xff8a6d1f),
                ),
                children: [
                  TextSpan(
                    text:
                        'This assistant helps you find products \u2014 it is ',
                  ),
                  TextSpan(
                    text: 'not medical advice',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text:
                        '. Always confirm medicines and dosages with a qualified pharmacist. Prescription-only items are verified before dispatch.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// EMPTY STATE CARD
/// ---------------------------------------------------------------------
class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: const Color(0xfff5f6f8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffe7e9ee)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xffdcebfd),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 26,
              color: Color(0xff2f6fed),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Upload a prescription \u2014 or just type a medicine name',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Color(0xff14181f),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap the clip icon to upload a photo or PDF, or type a medicine like \u201cParacetamol 500mg\u201d. I\u2019ll find it in our catalogue (or suggest a related option) so you can add it to your cart.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Color(0xff6b7280),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// BOTTOM CHAT INPUT BAR (pinned)
/// ---------------------------------------------------------------------
class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.onAttachTap,
    required this.onSend,
    required this.horizontalPadding,
  });

  final TextEditingController controller;
  final VoidCallback? onAttachTap;
  final VoidCallback onSend;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        10,
        horizontalPadding,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.attach_file,
                        size: 20,
                        color: Color(0xff6b7280),
                      ),
                      onPressed: onAttachTap,
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => onSend(),
                        decoration: const InputDecoration(
                          hintText:
                              'Upload a prescription or ask about a medicine\u2026',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xff9aa1ab),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: const TextStyle(fontSize: 14.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: const Color(0xff2f6fed),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onSend,
                child: const SizedBox(
                  width: 52,
                  child: Center(
                    child: Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
