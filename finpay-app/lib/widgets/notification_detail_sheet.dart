import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/fin_pay_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'modal_sheet_header.dart';

Future<void> showNotificationDetailSheet(
  BuildContext context,
  FinPayNotification notification,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          final title = notification.detailTitle ?? notification.title;
          final body = notification.detailParagraph ?? notification.body;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.paddingOf(context).bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ModalSheetHeader(
                  title: 'Notification details',
                  onClose: () => Navigator.of(ctx).pop(),
                ),
                const Divider(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _KindIcon(kind: notification.kind),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMM d, yyyy · hh:mm a').format(notification.timestamp),
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (notification.referenceId != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Ref: ${notification.referenceId}',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          body,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (notification.detailBullets.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...notification.detailBullets.map(
                            (b) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (notification.actionHint != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    notification.actionHint!,
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _KindIcon extends StatelessWidget {
  const _KindIcon({required this.kind});

  final FinPayNotificationKind kind;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (kind) {
      FinPayNotificationKind.security => (Icons.shield_outlined, AppColors.red),
      FinPayNotificationKind.payment => (Icons.payments_outlined, AppColors.green),
      FinPayNotificationKind.promo => (Icons.card_giftcard_outlined, AppColors.accent),
      FinPayNotificationKind.account => (Icons.account_circle_outlined, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
