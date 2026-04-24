import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';

class ProfilePhotoAvatar extends StatelessWidget {
  const ProfilePhotoAvatar({
    super.key,
    this.radius = 36,
    this.borderWidth = 2,
    this.profilePhotoPath,
  });

  final double radius;
  final double borderWidth;
  final String? profilePhotoPath;

  @override
  Widget build(BuildContext context) {
    final inner = radius - borderWidth;
    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.border,
      ),
      child: CircleAvatar(
        radius: inner,
        backgroundColor: AppColors.card,
        child: profilePhotoPath != null
            ? ClipOval(
                child: Image.file(
                  File(profilePhotoPath!),
                  width: inner * 2,
                  height: inner * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    AppAssets.profilePhoto,
                    width: inner * 2,
                    height: inner * 2,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : ClipOval(
                child: Image.asset(
                  AppAssets.profilePhoto,
                  width: inner * 2,
                  height: inner * 2,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
