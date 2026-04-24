import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum FilterTabStyle {
  /// Dark chips with white text; active chip gets a blue outline.
  chipsOnDark,

  /// Legacy high-contrast pill (white active chip + dark text).
  invertedPill,
}

class FilterTabs extends StatelessWidget {
  const FilterTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.style = FilterTabStyle.chipsOnDark,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final FilterTabStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) {
        final selected = i == selectedIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 36,
                alignment: Alignment.center,
                decoration: _decoration(selected),
                child: Text(
                  labels[i],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textColor(selected),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Color _textColor(bool selected) {
    switch (style) {
      case FilterTabStyle.chipsOnDark:
        return AppColors.textPrimary;
      case FilterTabStyle.invertedPill:
        return selected ? AppColors.background : AppColors.textMuted;
    }
  }

  BoxDecoration _decoration(bool selected) {
    switch (style) {
      case FilterTabStyle.chipsOnDark:
        return BoxDecoration(
          color: Color(0xff232325),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        );
      case FilterTabStyle.invertedPill:
        return BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: selected ? Colors.white : AppColors.border),
        );
    }
  }
}
