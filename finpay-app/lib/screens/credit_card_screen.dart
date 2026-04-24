import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../widgets/fin_surface.dart';
import '../widgets/screen_labels.dart';

class CreditCardScreen extends StatelessWidget {
  const CreditCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Credit Card')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ScreenAreaLabel(text: 'Products'),
          const SizedBox(height: 4),
          Text('Credit', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          FinSurface(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Manage credit limits, billing cycles, and rewards from a dedicated credit workspace.',
              style: GoogleFonts.poppins(fontSize: 14, height: 1.55, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
