import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_pickers.dart';
import '../widgets/fin_surface.dart';
import '../widgets/profile_photo_avatar.dart';
import '../widgets/screen_labels.dart';
import '../widgets/settings_row.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.onOpenSettings,
    required this.onOpenEStatement,
    required this.onOpenCreditCard,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenEStatement;
  final VoidCallback onOpenCreditCard;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // const ScreenAreaLabel(text: 'My Profile'),
            // const SizedBox(height: 4),
            Text(
              'Profile',
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProfilePhotoAvatar(radius: 34, profilePhotoPath: user?.profilePhotoPath),
                    // Positioned(
                    //   right: -2,
                    //   bottom: -2,
                    //   child: Material(
                    //     color: AppColors.textPrimary,
                    //     shape: const CircleBorder(),
                    //     child: InkWell(
                    //       customBorder: const CircleBorder(),
                    //       onTap: () => pushSlideFromRight(context, const MyProfileScreen()),
                    //       child: const Padding(
                    //         padding: EdgeInsets.all(6),
                    //         child: Icon(Icons.edit, size: 16, color: AppColors.accent,),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              user?.name ?? 'Tayyab Sohail',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2C),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              user?.title ?? 'UX/UI Designer',
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.email ?? 'tayyabsohailabd@gmail.com',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // IconButton(
                //   style: IconButton.styleFrom(backgroundColor: AppColors.background),
                //   onPressed: () => pushSlideFromRight(context, const MyProfileScreen()),
                //   icon: const Icon(Icons.qr_code_2),
                // ),
              ],
            ),
            // const SizedBox(height: 16),
            // Row(
            //   children: [
            //     Image.asset(
            //       AppAssets.mastercardPng,
            //       height: 22,
            //       errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            //     ),
            //     const SizedBox(width: 8),
            //     Text(
            //       'mastercard',
            //       style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
            //     ),
            //   ],
            // ),
            // Divider here
            const SizedBox(height: 18),
            Divider(height: 1, color: AppColors.border.withValues(alpha: 1)),
            const SizedBox(height: 24),
            const ProfileSectionTitle(title: 'Profile Settings'),
            const SizedBox(height: 8),
            FinSurface(
              child: Column(
                children: [
                  SettingsNavRow(icon: Icons.description_outlined, label: 'E-Statement', onTap: widget.onOpenEStatement),
                  const Divider(height: 1),
                  SettingsNavRow(icon: Icons.credit_card, label: 'Credit Card', onTap: widget.onOpenCreditCard),
                  const Divider(height: 1),
                  SettingsNavRow(icon: Icons.settings_outlined, label: 'Settings', onTap: widget.onOpenSettings),
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
                  SettingsNavRow(icon: Icons.translate, label: 'Language', onTap: () => showLanguagePicker(context)),
                  const Divider(height: 1),
                  SettingsNavRow(icon: Icons.public, label: 'Country', onTap: () => showCountryPicker(context)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.logoutSurface,
                  foregroundColor: AppColors.logoutForeground,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final go = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.card,
                          title: Text('Logout', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
                          content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary))),
                            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Logout', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary))),
                          ],
                        ),
                      ) ??
                      false;
                  if (!go || !context.mounted) return;
                  await context.read<AuthProvider>().logout();
                },
                icon: const Icon(Icons.logout, size: 18),
                label: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
