import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/fin_pay_notification.dart';
import '../providers/notifications_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/fin_surface.dart';
import '../widgets/notification_detail_sheet.dart';

String _notificationDayHeader(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(d.year, d.month, d.day);
  if (target == today) return 'Today';
  if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('EEEE, MMM d').format(d);
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  List<Widget> _buildList(BuildContext context, List<FinPayNotification> items) {
    final widgets = <Widget>[];
    DateTime? lastDay;

    for (final n in items) {
      final day = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
      if (lastDay == null || day != lastDay) {
        lastDay = day;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 20, bottom: 10),
            child: Text(
              _notificationDayHeader(day),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FinSurface(
            padding: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: () {
                context.read<NotificationsProvider>().markRead(n.id);
                showNotificationDetailSheet(context, n.copyWith(read: true));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LeadingDot(read: n.read, kind: n.kind),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: n.read ? FontWeight.w400 : FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                DateFormat('h:mm a').format(n.timestamp),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            n.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              height: 1.35,
                              color: n.read ? AppColors.textMuted : AppColors.textSecondary,
                              fontWeight: n.read ? FontWeight.w400 : FontWeight.w500,
                            ),
                          ),
                          if (n.referenceId != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              n.referenceId!,
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textMuted.withValues(alpha: 0.7)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final items = provider.notifications;
    final unread = provider.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => context.read<NotificationsProvider>().markAllRead(),
              child: Text(
                'Mark all read',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.accent),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'No notifications yet',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: _buildList(context, items),
            ),
    );
  }
}

class _LeadingDot extends StatelessWidget {
  const _LeadingDot({required this.read, required this.kind});

  final bool read;
  final FinPayNotificationKind kind;

  @override
  Widget build(BuildContext context) {
    final color = switch (kind) {
      FinPayNotificationKind.security => AppColors.red,
      FinPayNotificationKind.payment => AppColors.accent,
      FinPayNotificationKind.promo => AppColors.green,
      FinPayNotificationKind.account => AppColors.textSecondary,
    };
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            switch (kind) {
              FinPayNotificationKind.security => Icons.shield_outlined,
              FinPayNotificationKind.payment => Icons.payments_outlined,
              FinPayNotificationKind.promo => Icons.card_giftcard_outlined,
              FinPayNotificationKind.account => Icons.notifications_outlined,
            },
            color: color,
            size: 22,
          ),
        ),
        if (!read)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
