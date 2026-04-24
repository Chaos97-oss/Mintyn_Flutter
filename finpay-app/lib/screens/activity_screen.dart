import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/chart_series.dart';
import '../navigation/route_transitions.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/section_header.dart';
import '../widgets/spending_area_chart.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../widgets/transaction_item.dart';
import '../widgets/screen_labels.dart';
import 'transaction_history_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.onOpenSendMoney});

  final VoidCallback onOpenSendMoney;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _filter = 0;

  static const _transferAssets = [
    AppAssets.recentTransfer1,
    AppAssets.recentTransfer2,
    AppAssets.recentTransfer3,
    AppAssets.recentTransfer4,
  ];

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'My Activity',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Total Spending',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1200\$',
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  FilterTabs(
                    labels: const ['Weekly', 'Monthly', 'Today', 'Year'],
                    selectedIndex: _filter,
                    onChanged: (i) => setState(() => _filter = i),
                    style: FilterTabStyle.chipsOnDark,
                  ),
                  const SizedBox(height: 12),
                  SpendingAreaChart(
                    key: ValueKey<int>(_filter),
                    height: 220,
                    selectionIndex: 2,
                    showSelectionGuideline: true,
                    series: ChartSeries.forActivityFilter(_filter),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Transfer',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child:
            SizedBox(
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < _transferAssets.length; i++)
                    Positioned(
                      left: i * 40,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: i == 0 ? AppColors.accent : AppColors.border, width: 2),
                          color: AppColors.background,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            _transferAssets[i],
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

                  ),
                InkWell(
                  onTap: widget.onOpenSendMoney,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(0xff272729),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.add, color: Color(0xff96C0FF), size: 28),
                  ),
                ),
                  ],),
                ]
              )
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
      ),
    );
  }
}
