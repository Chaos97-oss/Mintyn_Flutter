import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Drag handle + title row with explicit close for bottom sheets / modals.
class ModalSheetHeader extends StatelessWidget {
  const ModalSheetHeader({
    super.key,
    required this.title,
    this.onClose,
    this.showHandle = true,
  });

  final String title;
  final VoidCallback? onClose;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showHandle) ...[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
            IconButton(
              style: IconButton.styleFrom(backgroundColor: AppColors.background),
              onPressed: onClose ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }
}
