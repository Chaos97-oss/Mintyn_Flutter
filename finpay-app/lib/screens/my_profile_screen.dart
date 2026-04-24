import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../navigation/route_transitions.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/fin_surface.dart';
import '../widgets/profile_photo_avatar.dart';
import '../widgets/screen_labels.dart';
import '../widgets/settings_row.dart';
import 'credit_card_screen.dart';
import 'e_statement_screen.dart';
import 'settings_screen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // const ScreenAreaLabel(text: 'My Profile'),
          const SizedBox(height: 4),
          Text('Profile', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          FinSurface(
            padding: const EdgeInsets.all(16),
            radius: 20,
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProfilePhotoAvatar(radius: 34, profilePhotoPath: user?.profilePhotoPath),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Material(
                        color: AppColors.textPrimary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.edit, size: 16, color: AppColors.accent,),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user?.name ?? 'Tayyab Sohail',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
              ],
            ),
          ),
          const SizedBox(height: 18),
          const ProfileSectionTitle(title: 'Profile Settings'),
          FinSurface(
            child: Column(
              children: [
                SettingsNavRow(
                  icon: Icons.description_outlined,
                  label: 'E-Statement',
                  onTap: () => pushSlideFromRight(context, const EStatementScreen()),
                ),
                const Divider(height: 1),
                SettingsNavRow(
                  icon: Icons.credit_card,
                  label: 'Credit Card',
                  onTap: () => pushSlideFromRight(context, const CreditCardScreen()),
                ),
                const Divider(height: 1),
                SettingsNavRow(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => pushSlideFromRight(context, const SettingsScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
