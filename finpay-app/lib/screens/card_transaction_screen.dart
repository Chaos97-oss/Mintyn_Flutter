import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/chart_series.dart';
import '../models/payment_card_model.dart';
import '../navigation/route_transitions.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/modal_sheet_header.dart';
import '../widgets/payment_card.dart';
import '../widgets/section_header.dart';
import '../widgets/spending_area_chart.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../widgets/transaction_item.dart';
import 'transaction_history_screen.dart';

class CardTransactionScreen extends StatefulWidget {
  const CardTransactionScreen({super.key, this.card});

  final PaymentCardModel? card;

  @override
  State<CardTransactionScreen> createState() => _CardTransactionScreenState();
}

class _CardTransactionScreenState extends State<CardTransactionScreen> {
  int _range = 0;

  Future<void> _pickRange() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ModalSheetHeader(
                  title: 'Chart range',
                  onClose: () => Navigator.pop(ctx),
                  showHandle: true,
                ),
                const Divider(height: 1),
                for (var i = 0; i < 4; i++)
                  ListTile(
                    title: Text(['Weekly', 'Monthly', 'Yearly', 'Today'][i], style: GoogleFonts.poppins()),
                    onTap: () => Navigator.pop(ctx, i),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final card = widget.card ?? wallet.primaryCardForActiveKind();
    final labels = ['Weekly', 'Monthly', 'Yearly', 'Today'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Card Transaction'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (card != null)
            Transform.scale(
              scale: 0.85,
              child: PaymentCard(card: card, flipAngle: 0, padding: 18),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Total Spend  ',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: '30\$',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _pickRange,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Row(
                      children: [
                        Text(labels[_range], style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        const Icon(Icons.expand_more, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SpendingAreaChart(
            key: ValueKey<int>(_range),
            height: 220,
            selectionIndex: 2,
            showSelectionGuideline: true,
            series: ChartSeries.forCardRange(_range),
          ),
          const SizedBox(height: 18),
          SectionHeader(
            title: 'Transaction History',
            trailingLabel: 'See all',
            onTrailing: () => pushSlideFromRight(context, const TransactionHistoryScreen()),
          ),
          const SizedBox(height: 8),
          ...wallet.transactions.asMap().entries.map((e) {
            final t = e.value;
            return TransactionItem(
              transaction: t,
              showDivider: e.key != wallet.transactions.length - 1,
              onTap: () => showTransactionDetailSheet(context, t),
            );
          }),
        ],
      ),
    );
  }
}
