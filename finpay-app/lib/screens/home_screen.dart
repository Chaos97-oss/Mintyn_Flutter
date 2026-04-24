import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/chart_series.dart';
import '../providers/auth_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/ui_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/section_header.dart';
import '../widgets/spending_area_chart.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../widgets/transaction_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenSendMoney,
    required this.onOpenAddCash,
    required this.onOpenNotifications,
    required this.onOpenHistory,
    required this.onOpenProfileTab,
    required this.onOpenBillPay,
    required this.onOpenDonations,
    required this.onOpenDeposit,
  });

  final VoidCallback onOpenSendMoney;
  final VoidCallback onOpenAddCash;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenProfileTab;
  final VoidCallback onOpenBillPay;
  final VoidCallback onOpenDonations;
  final VoidCallback onOpenDeposit;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _filter = 0;
  late final AnimationController _balanceAnim;

  @override
  void initState() {
    super.initState();
    _balanceAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
  }

  @override
  void dispose() {
    _balanceAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wallet = context.watch<WalletProvider>();
    final ui = context.read<UiProvider>();
    final userName = auth.user?.name ?? 'Tayyab Sohail';
    final filtered = wallet.transactionsForHomeFilter(_filter);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.card,
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                child: Row(
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: AppColors.background),
                      onPressed: () => ui.toggleSidebar(),
                      icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome ',
                              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                            ),
                            TextSpan(
                              text: userName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Consumer<NotificationsProvider>(
                      builder: (context, notifs, _) {
                        final unread = notifs.unreadCount;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: widget.onOpenNotifications,
                              icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                            ),
                            if (unread > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    unread > 9 ? '9+' : '$unread',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                          child: Image.asset(
                            AppAssets.cardBackground,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.paymentCardGradient,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 20),
                                      Text(
                                        'Total Balance',
                                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 8),
                                      AnimatedBuilder(
                                        animation: _balanceAnim,
                                        builder: (context, _) {
                                          final v = wallet.balance *
                                              CurvedAnimation(parent: _balanceAnim, curve: Curves.easeOutCubic).value;
                                          return Text(
                                            '${NumberFormat('#,##0').format(v)}\$',
                                            style: GoogleFonts.poppins(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      AppAssets.mastercardPng,
                                      height: 28,
                                      errorBuilder: (_, __, ___) => const SizedBox(height: 28),
                                    ),
                                    const SizedBox(height: 16),
                                    Transform.translate(
                                      offset: const Offset(-20, 0),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.qr_code_scanner,
                                            color: AppColors.textSecondary.withValues(alpha: 0.95),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: widget.onOpenAddCash,
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add Cash'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: widget.onOpenSendMoney,
                                      icon: const Icon(Icons.north_east, size: 18),
                                      label: const Text('Send Money'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _QuickActions(
                  onBillPay: widget.onOpenBillPay,
                  onDonations: widget.onOpenDonations,
                  onDeposit: widget.onOpenDeposit,
                  onMore: widget.onOpenProfileTab,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: SectionHeader(
                  title: 'Transaction History',
                  trailingLabel: 'See all',
                  onTrailing: widget.onOpenHistory,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilterTabs(
                  labels: const ['Weekly', 'Monthly', 'Today'],
                  selectedIndex: _filter,
                  onChanged: (i) => setState(() => _filter = i),
                  style: FilterTabStyle.chipsOnDark,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SpendingAreaChart(
                  key: ValueKey<int>(_filter),
                  height: 200,
                  selectionIndex: 3,
                  showSelectionGuideline: true,
                  series: ChartSeries.forHomeFilter(_filter),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final t = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TransactionItem(
                      transaction: t,
                      onTap: () => showTransactionDetailSheet(context, t),
                      showDivider: index != filtered.length - 1,
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onBillPay,
    required this.onDonations,
    required this.onDeposit,
    required this.onMore,
  });

  final VoidCallback onBillPay;
  final VoidCallback onDonations;
  final VoidCallback onDeposit;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.smartphone, 'Bill Pay', onBillPay),
      (Icons.volunteer_activism, 'Donations', onDonations),
      (Icons.local_atm, 'Deposit', onDeposit),
      (Icons.grid_view_rounded, 'More', onMore),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final it in items) _QuickTile(icon: it.$1, label: it.$2, onTap: it.$3),
        ],
      ),
    );
  }
}

class _QuickTile extends StatefulWidget {
  const _QuickTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickTile> createState() => _QuickTileState();
}

class _QuickTileState extends State<_QuickTile> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.elasticOut,
        scale: _scale,
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(0xff2C2C2C),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(widget.icon, color: AppColors.textPrimary, size: 30),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
