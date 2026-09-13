import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';

Future<void> _showEditProfileSheet(
  BuildContext context,
  ProfileBloc bloc,
  ProfileData profile,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return BlocProvider.value(
        value: bloc,
        child: _EditProfileSheet(profile: profile),
      );
    },
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile});
  final ProfileData profile;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.profile.phone == 'Not available' ? '' : widget.profile.phone,
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (ProfileState previous, ProfileState current) =>
          previous.updateStatus != current.updateStatus,
      listener: (BuildContext context, ProfileState state) {
        if (state.updateStatus == ProfileUpdateStatus.success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully.')),
          );
        } else if (state.updateStatus == ProfileUpdateStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.updateError ?? 'Failed to update profile.'),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xffe5edf5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Text(
                  'Edit Contact Information',
                  style: TextStyle(
                    color: ProfileScreen.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) =>
                      (value == null || value.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) =>
                      (value == null || value.trim().isEmpty)
                      ? 'Phone is required'
                      : null,
                ),
                const SizedBox(height: 20),
                BlocBuilder<ProfileBloc, ProfileState>(
                  buildWhen: (ProfileState previous, ProfileState current) =>
                      previous.updateStatus != current.updateStatus,
                  builder: (BuildContext context, ProfileState state) {
                    final bool submitting =
                        state.updateStatus == ProfileUpdateStatus.submitting;
                    return FilledButton(
                      onPressed: submitting
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;
                              context.read<ProfileBloc>().add(
                                ProfileUpdateRequested(
                                  name: _nameController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                ),
                              );
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: ProfileScreen.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Profile'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
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
                SliverToBoxAdapter(child: _ProfileHero(profile: profile)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  sliver: SliverList.list(
                    children: <Widget>[
                      _InfoCard(
                        title: 'Contact Information',
                        titleIcon: Icons.people_alt_outlined,
                        showEdit: !profile.isGuest,
                        onEdit: () => _showEditProfileSheet(
                          context,
                          context.read<ProfileBloc>(),
                          profile,
                        ),
                        rows: <_Info>[
                          _Info(
                            Icons.person_outline,
                            'Full Name',
                            profile.name,
                          ),
                          _Info(Icons.phone_outlined, 'Phone', profile.phone),
                          _Info(Icons.mail_outline, 'Email', profile.email),
                        ],
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});
  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
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

class _Info {
  const _Info(this.icon, this.label, this.value) : green = false;
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
    this.onEdit,
  });
  final String title;
  final IconData titleIcon;
  final List<_Info> rows;
  final bool showEdit;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Stack(
      children: <Widget>[
        Positioned.fill(
          child: Transform.scale(
            scale: 1.18,
            child: Image.asset(
              'assets/images/box_grid_view.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 26, 14, 30),
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
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                ],
              ),
              for (int i = 0; i < rows.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: i < rows.length - 1
                        ? const Border(
                            bottom: BorderSide(color: Color(0xffe5edf5)),
                          )
                        : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _IconBox(rows[i].icon, small: true, green: rows[i].green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              rows[i].label,
                              style: const TextStyle(
                                color: ProfileScreen.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rows[i].value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: rows[i].green
                                    ? const Color(0xff0ba66a)
                                    : ProfileScreen.ink,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox(this.icon, {this.small = false, this.green = false});
  final IconData icon;
  final bool small;
  final bool green;
  @override
  Widget build(BuildContext context) {
    final Color color = green ? const Color(0xff0ba66a) : ProfileScreen.blue;
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
