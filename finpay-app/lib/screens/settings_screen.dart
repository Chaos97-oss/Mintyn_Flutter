import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/fin_surface.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_labels.dart';
import '../widgets/settings_row.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _title = TextEditingController();
  bool _biometrics = true;
  bool _analytics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = context.read<AuthProvider>().user;
      if (!mounted || u == null) return;
      setState(() => _syncFromUser(u));
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _title.dispose();
    super.dispose();
  }

  void _syncFromUser(AppUser? u) {
    if (u == null) return;
    _name.text = u.name;
    _email.text = u.email;
    _title.text = u.title;
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1200, imageQuality: 88);
    if (!mounted || picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final ext = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
    final outPath = p.join(dir.path, 'profile_${DateTime.now().millisecondsSinceEpoch}$ext');
    await File(picked.path).copy(outPath);
    if (!mounted) return;
    await context.read<AuthProvider>().updateProfile(profilePhotoPath: outPath);
    setState(() {});
  }

  Future<void> _choosePhotoSource() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Choose from library', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('Take photo', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            if (context.read<AuthProvider>().user?.profilePhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.red),
                title: Text('Remove photo', style: GoogleFonts.poppins(color: AppColors.red)),
                onTap: () => Navigator.pop(ctx, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'gallery') {
      await _pickPhoto(ImageSource.gallery);
    } else if (choice == 'camera') {
      await _pickPhoto(ImageSource.camera);
    } else if (choice == 'remove') {
      await context.read<AuthProvider>().updateProfile(clearPhoto: true);
      setState(() {});
    }
  }

  Future<void> _saveProfile() async {
    await context.read<AuthProvider>().updateProfile(
          name: _name.text.trim(),
          email: _email.text.trim(),
          title: _title.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
      backgroundColor: AppColors.green,
          content: Text('Profile updated', style: GoogleFonts.poppins())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // const ScreenAreaLabel(text: 'Account'),
          // const SizedBox(height: 4),
          Text('Profile', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          FinSurface(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _choosePhotoSource,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.background,
                              child: user?.profilePhotoPath != null
                                  ? ClipOval(
                                      child: Image.file(
                                        File(user!.profilePhotoPath!),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Text(
                                          user.initials,
                                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      user?.initials ?? '?',
                                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,),
                                    ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.textPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 16, color: AppColors.accent,),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Tap the photo to change it. Camera and photo library access are requested when needed.',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _name,
                    style: GoogleFonts.poppins(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Full name',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _title,
                    style: GoogleFonts.poppins(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Job title',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(label: 'Save profile', onPressed: user == null ? null : _saveProfile),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const ScreenAreaLabel(text: 'Preferences'),
          const SizedBox(height: 4),
          Text('Security & privacy', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          FinSurface(
            child: Column(
              children: [
                SettingsToggleRow(
                  icon: Icons.fingerprint,
                  label: 'Biometric login',
                  value: _biometrics,
                  onChanged: (v) => setState(() => _biometrics = v),
                ),
                const Divider(height: 1),
                SettingsToggleRow(
                  icon: Icons.analytics_outlined,
                  label: 'Share analytics',
                  value: _analytics,
                  onChanged: (v) => setState(() => _analytics = v),
                ),
                const Divider(height: 1),
                SettingsNavRow(icon: Icons.lock_outline, label: 'Security', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'FinPay v1.0.0',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
