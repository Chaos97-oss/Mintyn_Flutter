import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../navigation/route_transitions.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_pickers.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/custom_tab_bar.dart';
import 'activity_screen.dart';
import 'add_cash_screen.dart';
import 'bill_pay_screen.dart';
import 'card_screen.dart';
import 'card_transaction_screen.dart';
import 'credit_card_screen.dart';
import 'deposit_screen.dart';
import 'donations_screen.dart';
import 'e_statement_screen.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'send_money_screen.dart';
import 'settings_screen.dart';
import 'transaction_history_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  void _goTab(int i) => setState(() => _tab = i);

  void _returnToDashboard() => _goTab(0);

  void _openProfileTab() {
    context.read<UiProvider>().closeSidebar();
    _goTab(3);
  }

  ProfileScreen _profileScreen() {
    return ProfileScreen(
      onOpenSettings: () => pushSlideFromRight(context, const SettingsScreen()),
      onOpenEStatement: () => pushSlideFromRight(context, const EStatementScreen()),
      onOpenCreditCard: () => pushSlideFromRight(context, const CreditCardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _tab,
            children: [
              HomeScreen(
                onOpenSendMoney: () => pushSlideFromBottom(
                  context,
                  SendMoneyScreen(onCompleted: _returnToDashboard),
                ),
                onOpenAddCash: () => pushSlideFromBottom(
                  context,
                  AddCashScreen(onCompleted: _returnToDashboard),
                ),
                onOpenNotifications: () => pushSlideFromRight(context, const NotificationsScreen()),
                onOpenHistory: () => pushSlideFromRight(context, const TransactionHistoryScreen()),
                onOpenProfileTab: _openProfileTab,
                onOpenBillPay: () => pushSlideFromBottom(
                  context,
                  BillPayScreen(onCompleted: _returnToDashboard),
                ),
                onOpenDonations: () => pushSlideFromBottom(
                  context,
                  DonationsScreen(onCompleted: _returnToDashboard),
                ),
                onOpenDeposit: () => pushSlideFromBottom(
                  context,
                  DepositScreen(onCompleted: _returnToDashboard),
                ),
              ),
              CardScreen(
                onOpenCardTransactions: () => pushSlideFromRight(context, const CardTransactionScreen()),
              ),
              ActivityScreen(
                onOpenSendMoney: () => pushSlideFromBottom(
                  context,
                  SendMoneyScreen(onCompleted: _returnToDashboard),
                ),
              ),
              _profileScreen(),
            ],
          ),
          AppSidebarOverlay(
            onNavigateHome: () => _goTab(0),
            onNavigateCards: () => _goTab(1),
            onNavigateActivity: () => _goTab(2),
            onNavigateProfile: () => _goTab(3),
            onOpenEStatement: () => pushSlideFromRight(context, const EStatementScreen()),
            onOpenCreditCard: () => pushSlideFromRight(context, const CreditCardScreen()),
            onOpenSettings: () => pushSlideFromRight(context, const SettingsScreen()),
            onPickLanguage: () => showLanguagePicker(context),
            onPickCountry: () => showCountryPicker(context),
            onEditProfile: _openProfileTab,
            onLogout: () async {
              final auth = context.read<AuthProvider>();
              final go = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.background,
                      title: Text('Logout', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),),
                      content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary))),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Logout', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary))),
                      ],
                    ),
                  ) ??
                  false;
              if (!go) return;
              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
              await auth.logout();
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomTabBar(
        currentIndex: _tab,
        onChanged: (i) {
          context.read<UiProvider>().closeSidebar();
          _goTab(i);
        },
      ),
    );
  }
}
