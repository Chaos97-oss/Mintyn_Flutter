import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Receipt-style summary used on the full detail screen and for image export.
class TransactionReceiptCard extends StatelessWidget {
  const TransactionReceiptCard({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.isCredit ? AppColors.green : AppColors.red;
    final sign = transaction.isCredit ? '+' : '−';
    final when = DateFormat('MMM d, yyyy · hh:mm a').format(transaction.timestamp);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  transaction.status,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'FINPAY',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            transaction.title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            when,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  'Amount',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  '$sign \$${transaction.amount.abs().toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _kv('Channel', transaction.channel),
          _kv('Merchant / Counterparty', transaction.merchant.isEmpty ? '—' : transaction.merchant),
          _kv('Reference', transaction.referenceId.isEmpty ? '—' : transaction.referenceId),
          if (transaction.fee != 0) _kv('Fees', '\$${transaction.fee.abs().toStringAsFixed(2)}'),
          if (transaction.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: AppColors.border.withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            Text(
              'Notes',
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.notes,
              style: GoogleFonts.poppins(fontSize: 13, height: 1.45, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: AppColors.border.withValues(alpha: 0.6)),
          const SizedBox(height: 8),
          Text(
            'This document is your official FinPay transaction record.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              k,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
