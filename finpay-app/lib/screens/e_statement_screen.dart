import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/fin_surface.dart';
import '../widgets/screen_labels.dart';

class EStatementScreen extends StatelessWidget {
  const EStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('E-Statement')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ScreenAreaLabel(text: 'Documents'),
          const SizedBox(height: 4),
          Text('Statements', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          FinSurface(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly overview',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      AppAssets.lineChartExample,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.background),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Download monthly statements, manage delivery preferences, and keep records organized.',
                  style: GoogleFonts.poppins(fontSize: 14, height: 1.55, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
