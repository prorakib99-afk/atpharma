import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../bloc/profile/profile_state.dart';
import 'favorite_store.dart';
import 'screen_product_details.dart';

Future<void> signOutFromProfile(BuildContext context) async {
  await sl<LogoutUseCase>()();
  await FavoriteStore.instance.clear();
  await ProductCart.instance.clear();
  if (!context.mounted) return;
  Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoutes.startpage,
    (Route<dynamic> route) => false,
  );
}

/// ---------------------------------------------------------------------
/// DATA MODEL
/// ---------------------------------------------------------------------
class ProfileMenuAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const ProfileMenuAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });
}

/// ---------------------------------------------------------------------
/// FLOATING PROFILE SCREEN — small account dropdown menu, anchored near
/// wherever it's triggered from (e.g. an avatar button in an AppBar).
/// ---------------------------------------------------------------------
class FloatingProfileScreen extends StatelessWidget {
  const FloatingProfileScreen({
    super.key,
    this.avatarAssetPath,
    this.avatarUrl,
    this.name = 'Sabbir Shawon',
    this.role = 'Super Admin',
    this.width = 220,
    this.onProfileTap,
    this.onTrackOrderTap,
    this.onMyOrdersTap,
    this.onSignOutTap,
    this.showAccentTab = true,
  });

  final String? avatarAssetPath;
  final String? avatarUrl;
  final String name;
  final String role;
  final double width;
  final VoidCallback? onProfileTap;
  final VoidCallback? onTrackOrderTap;
  final VoidCallback? onMyOrdersTap;
  final VoidCallback? onSignOutTap;
  final bool showAccentTab;

  static const _accent = Color(0xff7c3aed);
  static const _textMuted = Color(0xff6b7280);

  /// Convenience helper — opens this menu as a floating overlay anchored
  /// just below-right of [anchorKey]'s widget (e.g. an avatar IconButton).
  static Future<void> show(
    BuildContext context, {
    String? avatarAssetPath,
    String name = 'Sabbir Shawon',
    String role = 'Super Admin',
    VoidCallback? onProfileTap,
    VoidCallback? onTrackOrderTap,
    VoidCallback? onMyOrdersTap,
    VoidCallback? onSignOutTap,
  }) async {
    final SessionManager sessionManager = sl<SessionManager>();
    ProfileData profile = ProfileData.fromSession(
      sessionManager.currentUser,
      isGuest: sessionManager.isGuestMode,
    );
    if (!profile.isGuest && sessionManager.hasAccessToken) {
      final result = await sl<AuthRepository>().getMyProfile();
      final user = result.dataOrNull;
      if (user != null) {
        profile = ProfileData.fromSession(user, isGuest: false);
      }
    }
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.05),
        transitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (context, anim, secondaryAnim) {
          return FadeTransition(
            opacity: anim,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Navigator.of(context).pop(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  return Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: isWide ? 84 : 88,
                        right: isWide ? 20 : 24,
                      ),
                      child: GestureDetector(
                        onTap: () {},
                        child: FloatingProfileScreen(
                          avatarAssetPath: profile.isGuest
                              ? null
                              : avatarAssetPath,
                          avatarUrl: profile.isGuest ? null : profile.avatarUrl,
                          name: profile.name,
                          role: profile.roleLine,
                          onProfileTap: () {
                            Navigator.of(context).pop();
                            onProfileTap?.call();
                          },
                          onMyOrdersTap: () {
                            Navigator.of(context).pop();
                            onMyOrdersTap?.call();
                          },
                          onTrackOrderTap: () {
                            Navigator.of(context).pop();
                            onTrackOrderTap?.call();
                          },
                          onSignOutTap: () {
                            Navigator.of(context).pop();
                            onSignOutTap?.call();
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth < width ? constraints.maxWidth : width)
            : width;

        final card = Container(
          width: effectiveWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffe5e7eb)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xffe5e7eb),
                      backgroundImage: avatarUrl?.trim().isNotEmpty == true
                          ? NetworkImage(avatarUrl!)
                          : avatarAssetPath != null
                          ? AssetImage(avatarAssetPath!)
                          : null,
                      child:
                          avatarUrl?.trim().isNotEmpty != true &&
                              avatarAssetPath == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            role,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    _MenuRow(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      subtitle: 'Manage your profile',
                      onTap: onProfileTap,
                    ),
                    _MenuRow(
                      icon: Icons.receipt_long_outlined,
                      title: 'My Orders',
                      subtitle: 'View your order history',
                      onTap: onMyOrdersTap,
                    ),
                    _MenuRow(
                      icon: Icons.local_shipping_outlined,
                      title: 'Track Order',
                      subtitle: 'See live delivery updates',
                      onTap: onTrackOrderTap,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _SignOutRow(onTap: onSignOutTap),
            ],
          ),
        );

        if (!showAccentTab) {
          return Material(color: Colors.transparent, child: card);
        }

        return Material(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              card,
              Positioned(
                left: -4,
                top: 52,
                child: Container(
                  width: 6,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// MENU ROW
/// ---------------------------------------------------------------------
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xfff1e9fe),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: const Color(0xff7c3aed)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff6b7280),
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
/// SIGN OUT ROW
/// ---------------------------------------------------------------------
class _SignOutRow extends StatelessWidget {
  const _SignOutRow({required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.logout_rounded, size: 17, color: Color(0xffdc2626)),
            SizedBox(width: 8),
            Text(
              'Sign out',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xffdc2626),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
