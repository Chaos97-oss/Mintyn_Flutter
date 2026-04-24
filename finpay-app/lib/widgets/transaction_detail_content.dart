import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../theme/app_colors.dart';

class TransactionDetailContent extends StatelessWidget {
  const TransactionDetailContent({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.isCredit ? AppColors.accent : AppColors.red;
    final sign = transaction.isCredit ? '+' : '−';
    final amount = '$sign ${transaction.amount.abs().toStringAsFixed(2)}\$';
    final when = DateFormat('MMM d, yyyy · hh:mm a').format(transaction.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                transaction.title,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: amountColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(when, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 38),
        _row('Status', transaction.status),
        _row('Channel', transaction.channel),
        _row('Merchant / Counterparty', transaction.merchant.isEmpty ? '—' : transaction.merchant),
        _row('Reference', transaction.referenceId.isEmpty ? '—' : transaction.referenceId),
        if (transaction.fee != 0) _row('Fees', '\$${transaction.fee.abs().toStringAsFixed(2)}'),
        if (transaction.notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Notes', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            transaction.notes,
            style: GoogleFonts.poppins(fontSize: 14, height: 1.45, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
