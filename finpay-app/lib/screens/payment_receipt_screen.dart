import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/primary_button.dart';

/// Full-screen success receipt (transfer, top-up, bill pay, etc.).
class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({
    super.key,
    required this.headline,
    required this.amount,
    required this.amountIsDebit,
    required this.reference,
    required this.completedAt,
    this.subtitle,
    this.rows = const [],
    this.footerNote,
  });

  final String headline;
  final double amount;
  final bool amountIsDebit;
  final String reference;
  final DateTime completedAt;
  final String? subtitle;
  final List<(String label, String value)> rows;
  final String? footerNote;

  @override
  Widget build(BuildContext context) {
    final amtStyle = GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: amountIsDebit ? AppColors.red : AppColors.green,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              headline,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Center(
            child: Text(
              '${amountIsDebit ? '−' : '+'} \$${amount.abs().toStringAsFixed(2)}',
              style: amtStyle,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _ReceiptRow(label: 'Status', value: 'Successful', emphasize: true),
                _ReceiptRow(
                  label: 'Date & time',
                  value: DateFormat('MMM d, yyyy · hh:mm a').format(completedAt),
                ),
                _ReceiptRow(label: 'Reference', value: reference),
                for (final r in rows) _ReceiptRow(label: r.$1, value: r.$2),
              ],
            ),
          ),
          if (footerNote != null) ...[
            const SizedBox(height: 16),
            Text(
              footerNote!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted, height: 1.4),
            ),
          ],
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Done',
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
                color: emphasize ? AppColors.green : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
