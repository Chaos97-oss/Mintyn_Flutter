import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MastercardLogo extends StatelessWidget {
  const MastercardLogo({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    final circle = size * 0.42;
    return SizedBox(
      width: size * 1.35,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: size * 0.15,
            child: _Dot(diameter: circle, color: AppColors.mastercardRed),
          ),
          Positioned(
            left: size * 0.38,
            top: size * 0.15,
            child: _Dot(diameter: circle, color: AppColors.mastercardOrange),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
