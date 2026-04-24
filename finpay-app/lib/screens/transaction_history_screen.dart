import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/transaction_grouping.dart';
import '../widgets/fin_surface.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../widgets/transaction_item.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<TransactionModel> _filter(List<TransactionModel> sorted, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return sorted;
    return sorted.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.merchant.toLowerCase().contains(q) ||
          t.referenceId.toLowerCase().contains(q) ||
          t.notes.toLowerCase().contains(q) ||
          t.channel.toLowerCase().contains(q) ||
          t.amount.toString().contains(q) ||
          t.status.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final sorted = wallet.transactionsSorted;
    final filtered = _filter(sorted, _search.text);
    final grouped = groupTransactionsByDay(filtered);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Transaction history', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search title, merchant, reference, amount…',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                ),
              ),
            ),
          ),
          if (filtered.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    sorted.isEmpty
                        ? 'No transactions yet.'
                        : 'No matches for your search.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: grouped.length,
                itemBuilder: (context, sectionIndex) {
                  final key = grouped.keys.elementAt(sectionIndex);
                  final items = grouped[key]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10, top: sectionIndex == 0 ? 0 : 16),
                        child: Text(
                          formatDayHeader(key),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      FinSurface(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < items.length; i++) ...[
                              TransactionItem(
                                transaction: items[i],
                                showDivider: false,
                                onTap: () => showTransactionDetailSheet(context, items[i]),
                              ),
                              if (i != items.length - 1)
                                const Divider(height: 1, indent: 16, endIndent: 16),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
