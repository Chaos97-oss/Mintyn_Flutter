import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../theme/app_colors.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDivider = true,
  });

  final TransactionModel transaction;
  final VoidCallback? onTap;
  final bool showDivider;

  IconData _iconFor(TransactionCategory c) {
    switch (c) {
      case TransactionCategory.wallet:
        return Icons.account_balance_wallet_outlined;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TransactionCategory.banking:
        return Icons.account_balance_outlined;
      case TransactionCategory.saving:
        return Icons.savings_outlined;
      case TransactionCategory.other:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mma').format(transaction.timestamp).toLowerCase();
    final date = DateFormat('MM-dd-yyyy').format(transaction.timestamp);
    final amountColor = transaction.isCredit ? AppColors.accent : AppColors.red;
    final sign = transaction.isCredit ? '+' : '−';
    final amountText = '$sign ${transaction.amount.abs().toStringAsFixed(0)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(_iconFor(transaction.category), color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$time · $date',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amountText,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            ),
            if (showDivider)
              Divider(height: 1, thickness: 0.5, color: AppColors.border),
          ],
        ),
      ),
    );
  }
}
