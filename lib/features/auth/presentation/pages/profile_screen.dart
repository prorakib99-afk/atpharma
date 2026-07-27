import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';

/// ---------------------------------------------------------------------
/// DATA MODELS
/// ---------------------------------------------------------------------
class InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class SessionInfo {
  final String device;
  final String ip;
  final String dateTime;
  final bool isThisDevice;
  const SessionInfo({
    required this.device,
    required this.ip,
    required this.dateTime,
    this.isThisDevice = false,
  });
}

/// ---------------------------------------------------------------------
/// PROFILE SCREEN
/// ---------------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.avatarAssetPath,
    this.name = 'Sabbir Shawon',
    this.status = 'Active',
    this.roleLine = 'Super Admin \u00b7 Management',
    this.email = 'sabbirshaawon@gmail.com',
    this.phone = '+8801750118746',
    this.accountType = 'Super Admin',
    this.department = 'Management',
    this.memberSince = '08 July 2026',
    this.sessions = const [
      SessionInfo(
        device: 'Windows 10',
        ip: '150.228.135.197',
        dateTime: '27 July 2026 at 16:05',
        isThisDevice: true,
      ),
      SessionInfo(
        device: 'Unknown Device',
        ip: '103.163.171.206',
        dateTime: '25 July 2026 at 01:48',
      ),
      SessionInfo(
        device: 'Unknown Device',
        ip: '150.228.135.191',
        dateTime: '21 July 2026 at 18:21',
      ),
      SessionInfo(
        device: 'Windows 10',
        ip: '150.228.135.191',
        dateTime: '21 July 2026 at 17:56',
      ),
    ],
  });

  final String? avatarAssetPath;
  final String name;
  final String status;
  final String roleLine;
  final String email;
  final String phone;
  final String accountType;
  final String department;
  final String memberSince;
  final List<SessionInfo> sessions;

  static const _primary = Color(0xff0b83d9);
  static const _primarySoft = Color(0xffe7f3fb);
  static const _textDark = Color(0xff131314);
  static const _textMuted = Color(0xff6b7280);
  static const _pageBg = Color(0xfff3f4f6);
  static const _cardBorder = Color(0xffe5e7eb);
  static const _activeGreenBg = Color(0xffdcfce7);
  static const _activeGreenText = Color(0xff16a34a);

  @override
  Widget build(BuildContext context) {
    return NavigationPageScaffold(
      currentPage: null,
      backgroundColor: _pageBg,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isWide = width >= 860;
            final horizontalPadding = width <= 500 ? 14.0 : 24.0;

            final contactCard = _SectionCard(
              title: 'Contact Information',
              leftItems: [
                InfoItem(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: name,
                ),
                InfoItem(
                  icon: Icons.call_outlined,
                  label: 'Business Phone',
                  value: phone,
                ),
              ],
              rightItems: [
                InfoItem(
                  icon: Icons.mail_outline,
                  label: 'Work Email',
                  value: email,
                ),
                InfoItem(
                  icon: Icons.verified_outlined,
                  label: 'Account Status',
                  value: status,
                ),
              ],
            );

            final roleCard = _SectionCard(
              title: 'Role & Access',
              leftItems: [
                InfoItem(
                  icon: Icons.shield_outlined,
                  label: 'Role',
                  value: accountType,
                ),
                InfoItem(
                  icon: Icons.verified_user_outlined,
                  label: 'Account Type',
                  value: accountType,
                ),
              ],
              rightItems: [
                InfoItem(
                  icon: Icons.apartment_outlined,
                  label: 'Department',
                  value: department,
                ),
                InfoItem(
                  icon: Icons.event_outlined,
                  label: 'Member Since',
                  value: memberSince,
                ),
              ],
            );

            final activityCard = _SectionCard(
              title: 'Account Activity',
              leftItems: [
                InfoItem(
                  icon: Icons.access_time,
                  label: 'Last Login',
                  value: sessions.isNotEmpty
                      ? sessions.first.dateTime
                      : '\u2014',
                ),
                InfoItem(
                  icon: Icons.location_on_outlined,
                  label: 'Login Location',
                  value: sessions.isNotEmpty ? sessions.first.ip : '\u2014',
                ),
              ],
              rightItems: [
                InfoItem(
                  icon: Icons.devices_outlined,
                  label: 'Login Device',
                  value: sessions.isNotEmpty ? sessions.first.device : '\u2014',
                ),
                InfoItem(
                  icon: Icons.public,
                  label: 'Active Sessions',
                  value: '${sessions.length}',
                ),
              ],
            );

            final securityCard = _SectionCard(
              title: 'Security & Preferences',
              leftItems: const [
                InfoItem(
                  icon: Icons.no_encryption_gmailerrorred,
                  label: 'Two-factor Authentication',
                  value: 'Disabled',
                ),
                InfoItem(
                  icon: Icons.tonality,
                  label: 'Appearance',
                  value: 'Light',
                ),
              ],
              rightItems: const [
                InfoItem(
                  icon: Icons.notifications_none,
                  label: 'Login Alerts',
                  value: 'Disabled',
                ),
                InfoItem(
                  icon: Icons.event_note_outlined,
                  label: 'Profile Updated',
                  value: '17 July 2026',
                ),
              ],
            );

            final permissionCard = _PermissionScopeCard(
              accessLabel: 'Full access to all modules',
            );

            final sessionsCard = _RecentSessionsCard(sessions: sessions);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                124,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => Navigator.of(
                          context,
                        ).pushReplacementNamed(AppRoutes.home),
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 26,
                            color: _textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ProfileHeaderCard(
                    avatarAssetPath: avatarAssetPath,
                    name: name,
                    status: status,
                    roleLine: roleLine,
                    email: email,
                    phone: phone,
                    accountType: accountType,
                    department: department,
                    memberSince: memberSince,
                    isWide: isWide,
                  ),
                  const SizedBox(height: 16),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: contactCard),
                        const SizedBox(width: 16),
                        Expanded(child: roleCard),
                      ],
                    )
                  else ...[
                    contactCard,
                    const SizedBox(height: 16),
                    roleCard,
                  ],
                  const SizedBox(height: 16),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: activityCard),
                        const SizedBox(width: 16),
                        Expanded(child: securityCard),
                      ],
                    )
                  else ...[
                    activityCard,
                    const SizedBox(height: 16),
                    securityCard,
                  ],
                  const SizedBox(height: 16),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: permissionCard),
                        const SizedBox(width: 16),
                        Expanded(flex: 3, child: sessionsCard),
                      ],
                    )
                  else ...[
                    permissionCard,
                    const SizedBox(height: 16),
                    sessionsCard,
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// HEADER CARD
/// ---------------------------------------------------------------------
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.avatarAssetPath,
    required this.name,
    required this.status,
    required this.roleLine,
    required this.email,
    required this.phone,
    required this.accountType,
    required this.department,
    required this.memberSince,
    required this.isWide,
  });

  final String? avatarAssetPath;
  final String name;
  final String status;
  final String roleLine;
  final String email;
  final String phone;
  final String accountType;
  final String department;
  final String memberSince;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final identity = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: const Color(0xffe5e7eb),
          backgroundImage: avatarAssetPath != null
              ? AssetImage(avatarAssetPath!)
              : null,
          child: avatarAssetPath == null
              ? const Icon(Icons.person, color: Colors.white, size: 30)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 4,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffdcfce7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff16a34a),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                roleLine,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xff6b7280),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  _ContactBit(icon: Icons.mail_outline, text: email),
                  _ContactBit(icon: Icons.call_outlined, text: phone),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final chips = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _HeaderStatChip(label: 'Account Type', value: accountType),
        _HeaderStatChip(label: 'Department', value: department),
        _HeaderStatChip(label: 'Member Since', value: memberSince),
      ],
    );

    return _Card(
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: identity),
                const SizedBox(width: 16),
                chips,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [identity, const SizedBox(height: 16), chips],
            ),
    );
  }
}

class _ContactBit extends StatelessWidget {
  const _ContactBit({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xff0b83d9)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12.5, color: Color(0xff374151)),
        ),
      ],
    );
  }
}

class _HeaderStatChip extends StatelessWidget {
  const _HeaderStatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xfff9fafb),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xff9aa1ab)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// GENERIC SECTION CARD (title + 2-column info rows)
/// ---------------------------------------------------------------------
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.leftItems,
    required this.rightItems,
  });

  final String title;
  final List<InfoItem> leftItems;
  final List<InfoItem> rightItems;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stack = constraints.maxWidth < 340;
              final leftColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < leftItems.length; i++) ...[
                    _InfoRow(item: leftItems[i]),
                    if (i != leftItems.length - 1) const SizedBox(height: 16),
                  ],
                ],
              );
              final rightColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < rightItems.length; i++) ...[
                    _InfoRow(item: rightItems[i]),
                    if (i != rightItems.length - 1) const SizedBox(height: 16),
                  ],
                ],
              );

              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftColumn,
                    const SizedBox(height: 16),
                    rightColumn,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: leftColumn),
                  const SizedBox(width: 16),
                  Expanded(child: rightColumn),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item});
  final InfoItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffe7f3fb),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(item.icon, size: 16, color: const Color(0xff0b83d9)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(fontSize: 12, color: Color(0xff9aa1ab)),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// PERMISSION SCOPE CARD
/// ---------------------------------------------------------------------
class _PermissionScopeCard extends StatelessWidget {
  const _PermissionScopeCard({required this.accessLabel});
  final String accessLabel;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xffe7f3fb),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: Color(0xff0b83d9),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permission Scope',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Access groups assigned to this account.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffe5e7eb)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 17,
                  color: Color(0xff16a34a),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    accessLabel,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
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
/// RECENT SESSIONS CARD
/// ---------------------------------------------------------------------
class _RecentSessionsCard extends StatelessWidget {
  const _RecentSessionsCard({required this.sessions});
  final List<SessionInfo> sessions;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xffe7f3fb),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.devices_outlined,
                  size: 16,
                  color: Color(0xff0b83d9),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Sessions',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Devices currently signed in to this account.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < sessions.length; i++) ...[
            _SessionRow(session: sessions[i]),
            if (i != sessions.length - 1)
              Divider(height: 24, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final SessionInfo session;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 380;
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  session.device,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (session.isThisDevice)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffe6fbf6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'This device',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff0d9488),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              session.ip,
              style: const TextStyle(fontSize: 12.5, color: Color(0xff9aa1ab)),
            ),
          ],
        );
        final right = Text(
          session.dateTime,
          style: const TextStyle(fontSize: 12.5, color: Color(0xff0b83d9)),
        );

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [left, const SizedBox(height: 4), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            right,
          ],
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// SHARED CARD SHELL
/// ---------------------------------------------------------------------
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: child,
    );
  }
}
