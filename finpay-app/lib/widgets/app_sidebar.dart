import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import '../theme/app_colors.dart';
import 'fin_surface.dart';
import 'profile_photo_avatar.dart';
import 'screen_labels.dart';
import 'settings_row.dart';

class AppSidebarOverlay extends StatefulWidget {
  const AppSidebarOverlay({
    super.key,
    required this.onNavigateHome,
    required this.onNavigateCards,
    required this.onNavigateActivity,
    required this.onNavigateProfile,
    required this.onOpenEStatement,
    required this.onOpenCreditCard,
    required this.onOpenSettings,
    required this.onPickLanguage,
    required this.onPickCountry,
    required this.onEditProfile,
    required this.onLogout,
  });

  final VoidCallback onNavigateHome;
  final VoidCallback onNavigateCards;
  final VoidCallback onNavigateActivity;
  final VoidCallback onNavigateProfile;
  final VoidCallback onOpenEStatement;
  final VoidCallback onOpenCreditCard;
  final VoidCallback onOpenSettings;
  final VoidCallback onPickLanguage;
  final VoidCallback onPickCountry;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  @override
  State<AppSidebarOverlay> createState() => _AppSidebarOverlayState();
}

class _AppSidebarOverlayState extends State<AppSidebarOverlay> with SingleTickerProviderStateMixin {
  bool _notifications = true;
  late final AnimationController _open;
  late final Animation<double> _scrim;
  late final Animation<Offset> _slide;
  late final UiProvider _ui;

  @override
  void initState() {
    super.initState();
    _ui = context.read<UiProvider>();
    _open = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    final curved = CurvedAnimation(
      parent: _open,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _scrim = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(curved);
    _ui.addListener(_syncFromUi);
    if (_ui.sidebarOpen) {
      _open.value = 1;
    }
  }

  void _syncFromUi() {
    if (!mounted) return;
    if (_ui.sidebarOpen) {
      _open.forward();
    } else {
      _open.reverse();
    }
  }

  @override
  void dispose() {
    _ui.removeListener(_syncFromUi);
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.75;

    return Positioned.fill(
      child: ListenableBuilder(
        listenable: _open,
        builder: (context, _) {
          return IgnorePointer(
            ignoring: _open.isDismissed,
            child: Stack(
              children: [
                FadeTransition(
                  opacity: _scrim,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.read<UiProvider>().closeSidebar(),
                    child: Container(color: AppColors.overlayScrim),
                  ),
                ),
                SlideTransition(
                  position: _slide,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: AppColors.background,
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.45),
                      child: SizedBox(
                        width: width,
                        height: double.infinity,
                        child: SafeArea(
                          child: Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              final user = auth.user;
                              final name = user?.name ?? 'Tayyab Sohail';
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        ProfilePhotoAvatar(radius: 34, profilePhotoPath: auth.user?.profilePhotoPath),
                                        Positioned(
                                          right: -2,
                                          bottom: -2,
                                          child: Material(
                                            color: AppColors.textPrimary.withValues(alpha: 0.9),
                                            shape: const CircleBorder(),
                                            child: InkWell(
                                              customBorder: const CircleBorder(),
                                              onTap: () {
                                                context.read<UiProvider>().closeSidebar();
                                                widget.onEditProfile();
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Icon(Icons.edit, size: 16, color: AppColors.accent),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Welcome',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.5)),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const ProfileSectionTitle(title: 'Profile Settings'),
                                            FinSurface(
                                              child: Column(
                                                children: [
                                                  SettingsNavRow(
                                                    icon: Icons.description_outlined,
                                                    label: 'E-Statement',
                                                    onTap: () {
                                                      context.read<UiProvider>().closeSidebar();
                                                      widget.onOpenEStatement();
                                                    },
                                                  ),
                                                  const Divider(height: 1),
                                                  SettingsNavRow(
                                                    icon: Icons.credit_card,
                                                    label: 'Credit Card',
                                                    onTap: () {
                                                      context.read<UiProvider>().closeSidebar();
                                                      widget.onOpenCreditCard();
                                                    },
                                                  ),
                                                  const Divider(height: 1),
                                                  SettingsNavRow(
                                                    icon: Icons.settings_outlined,
                                                    label: 'Settings',
                                                    onTap: () {
                                                      context.read<UiProvider>().closeSidebar();
                                                      widget.onOpenSettings();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const ProfileSectionTitle(title: 'Notification'),
                                            FinSurface(
                                              child: SettingsToggleRow(
                                                icon: Icons.notifications_none,
                                                label: 'App Notification',
                                                value: _notifications,
                                                onChanged: (v) => setState(() => _notifications = v),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const ProfileSectionTitle(title: 'More'),
                                            FinSurface(
                                              child: Column(
                                                children: [
                                                  SettingsNavRow(
                                                    icon: Icons.translate,
                                                    label: 'Language',
                                                    onTap: () {
                                                      context.read<UiProvider>().closeSidebar();
                                                      widget.onPickLanguage();
                                                    },
                                                  ),
                                                  const Divider(height: 1),
                                                  SettingsNavRow(
                                                    icon: Icons.public,
                                                    label: 'Country',
                                                    onTap: () {
                                                      context.read<UiProvider>().closeSidebar();
                                                      widget.onPickCountry();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 18),
                                            SizedBox(
                                              width: double.infinity,
                                              child: FilledButton.icon(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: AppColors.logoutSurface,
                                                  foregroundColor: AppColors.logoutForeground,
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                onPressed: () {
                                                  context.read<UiProvider>().closeSidebar();
                                                  widget.onLogout();
                                                },
                                                icon: const Icon(Icons.logout, size: 18),
                                                label: Text(
                                                  'Logout',
                                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
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
