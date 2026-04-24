import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(12, 6, 12, 8 + bottom),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            _Tab(
              icon: Icons.home_outlined,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => onChanged(0),
            ),
            _Tab(
              icon: Icons.credit_card,
              label: 'Card',
              selected: currentIndex == 1,
              onTap: () => onChanged(1),
            ),
            _Tab(
              icon: Icons.pie_chart_outline,
              label: 'Activity',
              selected: currentIndex == 2,
              onTap: () => onChanged(2),
            ),
            _Tab(
              icon: Icons.person_outline,
              label: 'Profile',
              selected: currentIndex == 3,
              onTap: () => onChanged(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> with SingleTickerProviderStateMixin {
  double _pressed = 1;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected ? AppColors.textPrimary : AppColors.textMuted;
    final scale = widget.selected ? 1.15 : 1.0;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = 0.7),
        onTapCancel: () => setState(() => _pressed = 1),
        onTapUp: (_) => setState(() => _pressed = 1),
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: _pressed,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 8,
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: widget.selected ? 1 : 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        width: widget.selected ? 4 : 0,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                Icon(widget.icon, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
