import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

Future<void> showLanguagePicker(BuildContext context) async {
  await showModalBottomSheet<void>(
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
            title: Text('English', style: GoogleFonts.poppins()),
            onTap: () => Navigator.pop(ctx),
          ),
          ListTile(
            title: Text('Español', style: GoogleFonts.poppins()),
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );
}

Future<void> showCountryPicker(BuildContext context) async {
  await showModalBottomSheet<void>(
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
            title: Text('United States', style: GoogleFonts.poppins()),
            onTap: () => Navigator.pop(ctx),
          ),
          ListTile(
            title: Text('United Kingdom', style: GoogleFonts.poppins()),
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );
}
