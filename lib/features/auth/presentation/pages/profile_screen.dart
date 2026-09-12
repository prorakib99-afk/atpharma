import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';

class SessionInfo {
  const SessionInfo({
    required this.device,
    required this.ip,
    required this.dateTime,
    this.isThisDevice = false,
  });
  final String device;
  final String ip;
  final String dateTime;
  final bool isThisDevice;
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.sessions = const <SessionInfo>[
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

  final List<SessionInfo> sessions;
  static const Color blue = Color(0xff087cf0);
  static const Color page = Color(0xfff4f8fc);
  static const Color ink = Color(0xff10142c);
  static const Color muted = Color(0xff7585a5);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final ProfileData? profile = state.profile;
        if (profile == null && state.status == ProfileStatus.loading) {
          return const NavigationPageScaffold(
            currentPage: null,
            backgroundColor: page,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (profile == null) {
          return NavigationPageScaffold(
            currentPage: null,
            backgroundColor: page,
            body: Center(
              child: FilledButton(
                onPressed: () =>
                    context.read<ProfileBloc>().add(const ProfileRequested()),
                child: const Text('Try again'),
              ),
            ),
          );
        }
        final SessionInfo? current = sessions.isEmpty ? null : sessions.first;
        return NavigationPageScaffold(
          currentPage: null,
          backgroundColor: page,
          extendBody: true,
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(const ProfileRequested());
              await context.read<ProfileBloc>().stream.firstWhere(
                (ProfileState value) => value.status != ProfileStatus.loading,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: _ProfileHero(
                    profile: profile,
                    sessionCount: sessions.length,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  sliver: SliverList.list(
                    children: <Widget>[
                      _InfoCard(
                        title: 'Contact Information',
                        titleIcon: Icons.people_alt_outlined,
                        showEdit: !profile.isGuest,
                        rows: <_Info>[
                          _Info(
                            Icons.person_outline,
                            'Full Name',
                            profile.name,
                          ),
                          _Info(
                            Icons.phone_outlined,
                            'Business Phone',
                            profile.phone,
                          ),
                          _Info(
                            Icons.mail_outline,
                            'Work Email',
                            profile.email,
                          ),
                          _Info(
                            Icons.verified_user_outlined,
                            'Account Status',
                            profile.status,
                            green: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _InfoCard(
                        title: 'Account Activity',
                        titleIcon: Icons.schedule,
                        rows: <_Info>[
                          _Info(
                            Icons.schedule,
                            'Last Login',
                            current?.dateTime ?? 'Not available',
                          ),
                          _Info(
                            Icons.location_on_outlined,
                            'Login Location',
                            current?.ip ?? 'Not available',
                          ),
                          _Info(
                            Icons.desktop_windows_outlined,
                            'Login Device',
                            current?.device ?? 'Not available',
                          ),
                          _Info(
                            Icons.people_outline,
                            'Active Sessions',
                            sessions.length.toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SessionsCard(items: sessions),
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile, required this.sessionCount});
  final ProfileData profile;
  final int sessionCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            height: 215,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sky.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(330, 82),
              ),
            ),
          ),
          Positioned(
            left: -55,
            right: -55,
            top: 166,
            child: Container(
              height: 116,
              decoration: BoxDecoration(
                color: ProfileScreen.page.withValues(alpha: .88),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.elliptical(340, 92),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 18,
            child: _RoundButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                }
              },
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 18,
            child: _RoundButton(icon: Icons.more_horiz_rounded, onTap: () {}),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 70,
            child: Column(
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      width: 86,
                      height: 86,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: ProfileScreen.blue.withValues(alpha: .16),
                            spreadRadius: 9,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xffdfe4ea),
                        backgroundImage: profile.avatarUrl == null
                            ? null
                            : NetworkImage(profile.avatarUrl!),
                        child: profile.avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 38,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 5,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: const Color(0xff18bd7b),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ProfileScreen.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffdcf8e9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.status,
                    style: const TextStyle(
                      color: Color(0xff08a668),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.roleLine,
                  style: const TextStyle(
                    color: ProfileScreen.muted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _Summary(
                    icon: Icons.person_outline,
                    label: 'Account Type',
                    value: profile.accountType,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Summary(
                    icon: Icons.layers_outlined,
                    label: 'Active Sessions',
                    value: sessionCount.toString(),
                    purple: true,
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

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: .9),
    shape: const CircleBorder(),
    elevation: 2,
    child: IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      color: ProfileScreen.blue,
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.icon,
    required this.label,
    required this.value,
    this.purple = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool purple;
  @override
  Widget build(BuildContext context) => Container(
    height: 76,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: _cardDecoration,
    child: Row(
      children: <Widget>[
        _IconBox(icon, purple: purple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ProfileScreen.muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ProfileScreen.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Info {
  const _Info(this.icon, this.label, this.value, {this.green = false});
  final IconData icon;
  final String label;
  final String value;
  final bool green;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.titleIcon,
    required this.rows,
    this.showEdit = false,
  });
  final String title;
  final IconData titleIcon;
  final List<_Info> rows;
  final bool showEdit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 15, 14, 8),
    decoration: _cardDecoration,
    child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _IconBox(titleIcon),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: ProfileScreen.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (showEdit)
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
          ],
        ),
        for (int i = 0; i < rows.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: i < rows.length - 1
                  ? const Border(bottom: BorderSide(color: Color(0xffe5edf5)))
                  : null,
            ),
            child: Row(
              children: <Widget>[
                _IconBox(rows[i].icon, small: true, green: rows[i].green),
                const SizedBox(width: 12),
                SizedBox(
                  width: 116,
                  child: Text(
                    rows[i].label,
                    style: const TextStyle(
                      color: ProfileScreen.muted,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rows[i].value,
                    style: TextStyle(
                      color: rows[i].green
                          ? const Color(0xff0ba66a)
                          : ProfileScreen.ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
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

class _SessionsCard extends StatelessWidget {
  const _SessionsCard({required this.items});
  final List<SessionInfo> items;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 15, 14, 8),
    decoration: _cardDecoration,
    child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const _IconBox(Icons.desktop_windows_outlined, purple: true),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Recent Sessions',
                    style: TextStyle(
                      color: ProfileScreen.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Devices currently signed in to this account.',
                    style: TextStyle(color: ProfileScreen.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
            const Icon(Icons.chevron_right_rounded, color: ProfileScreen.muted),
          ],
        ),
        for (int i = 0; i < items.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: i < items.length - 1
                  ? const Border(bottom: BorderSide(color: Color(0xffe5edf5)))
                  : null,
            ),
            child: Row(
              children: <Widget>[
                const _IconBox(Icons.desktop_windows_outlined, small: true),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        spacing: 10,
                        children: <Widget>[
                          Text(
                            items[i].device,
                            style: const TextStyle(
                              color: ProfileScreen.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            items[i].ip,
                            style: const TextStyle(
                              color: ProfileScreen.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        items[i].dateTime,
                        style: const TextStyle(
                          color: ProfileScreen.blue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (items[i].isThisDevice)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffdcf8e9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'This device',
                      style: TextStyle(color: Color(0xff0ba66a), fontSize: 11),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: ProfileScreen.muted,
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox(
    this.icon, {
    this.small = false,
    this.purple = false,
    this.green = false,
  });
  final IconData icon;
  final bool small;
  final bool purple;
  final bool green;
  @override
  Widget build(BuildContext context) {
    final Color color = green
        ? const Color(0xff0ba66a)
        : purple
        ? const Color(0xff4e5cf5)
        : ProfileScreen.blue;
    return Container(
      width: small ? 36 : 46,
      height: small ? 36 : 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: small ? 20 : 25),
    );
  }
}

final BoxDecoration _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  boxShadow: const <BoxShadow>[
    BoxShadow(color: Color(0x100d4d83), blurRadius: 24, offset: Offset(0, 8)),
  ],
);
