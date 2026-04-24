import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/fin_surface.dart';
import '../widgets/modal_sheet_header.dart';
import '../widgets/primary_button.dart';
import 'payment_receipt_screen.dart';

enum _AddCashStep { amount, method, processing }

class AddCashScreen extends StatefulWidget {
  const AddCashScreen({super.key, this.onCompleted});

  /// Called after the sheet is closed so the shell can return to the home tab.
  final VoidCallback? onCompleted;

  @override
  State<AddCashScreen> createState() => _AddCashScreenState();
}

class _AddCashScreenState extends State<AddCashScreen> {
  _AddCashStep _step = _AddCashStep.amount;
  double? _amount;
  String _method = 'Debit card';
  final _amountField = TextEditingController();

  static const _presets = [25.0, 50.0, 100.0, 200.0, 500.0];
  static const _methods = ['Debit card', 'Bank transfer', 'Apple Pay'];

  @override
  void initState() {
    super.initState();
    _amountField.addListener(_onCustomAmountChanged);
  }

  void _onCustomAmountChanged() {
    final t = _amountField.text.trim();
    if (t.isEmpty) {
      setState(() => _amount = null);
      return;
    }
    final v = double.tryParse(t);
    setState(() => _amount = v != null && v > 0 ? v : null);
  }

  void _applyPreset(double p) {
    _amountField.removeListener(_onCustomAmountChanged);
    _amountField.text = p % 1 == 0 ? '${p.toInt()}' : '$p';
    _amountField.addListener(_onCustomAmountChanged);
    setState(() => _amount = p);
  }

  @override
  void dispose() {
    _amountField.removeListener(_onCustomAmountChanged);
    _amountField.dispose();
    super.dispose();
  }

  Future<void> _runGateway() async {
    final amount = _amount;
    if (amount == null || amount <= 0) return;
    setState(() => _step = _AddCashStep.processing);
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final wallet = context.read<WalletProvider>();
    final ref = wallet.recordReceive(
      amount: amount,
      title: 'Wallet top-up',
      category: TransactionCategory.wallet,
      merchant: 'FinPay Payments',
      notes: _method,
      channel: _method,
    );

    if (!mounted || ref.isEmpty) return;
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => PaymentReceiptScreen(
          headline: 'Top-up successful',
          subtitle: 'Your wallet balance has been updated in real time.',
          amount: amount,
          amountIsDebit: false,
          reference: ref,
          completedAt: DateTime.now(),
          rows: [
            ('Payment method', _method),
            ('Settlement', 'Instant'),
          ],
          footerNote: 'Funds are available for transfers and bill payments immediately.',
        ),
      ),
    );
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModalSheetHeader(
                title: 'Add cash',
                onClose: () => Navigator.of(context).maybePop(),
              ),
              if (_step != _AddCashStep.amount && _step != _AddCashStep.processing)
                TextButton.icon(
                  onPressed: () => setState(() => _step = _AddCashStep.amount),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  label: const Text('Edit amount'),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _step == _AddCashStep.amount
                      ? _AmountPanel(
                          key: const ValueKey('amt'),
                          presets: _presets,
                          amountController: _amountField,
                          selectedAmount: _amount,
                          onPreset: _applyPreset,
                          onContinue: _amount == null || _amount! <= 0
                              ? null
                              : () => setState(() => _step = _AddCashStep.method),
                        )
                      : _step == _AddCashStep.method
                          ? _MethodPanel(
                              key: const ValueKey('meth'),
                              methods: _methods,
                              selected: _method,
                              onSelect: (m) => setState(() => _method = m),
                              amount: _amount!,
                              onPay: _runGateway,
                            )
                          : const _ProcessingPanel(key: ValueKey('proc')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountPanel extends StatelessWidget {
  const _AmountPanel({
    super.key,
    required this.presets,
    required this.amountController,
    required this.selectedAmount,
    required this.onPreset,
    required this.onContinue,
  });

  final List<double> presets;
  final TextEditingController amountController;
  final double? selectedAmount;
  final ValueChanged<double> onPreset;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          'How much do you want to add?',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick a quick amount or type any value below.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final p in presets)
              ChoiceChip(
                label: Text('\$${p.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                selected: selectedAmount != null && (selectedAmount! - p).abs() < 0.001,
                onSelected: (_) => onPreset(p),
                selectedColor: AppColors.accent.withValues(alpha: 0.35),
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: AppColors.border),
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Custom amount',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: GoogleFonts.poppins(fontSize: 22, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. 75.50',
            prefixText: '\$ ',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        FinSurface(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text('You will add', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
              const Spacer(),
              Text(
                selectedAmount != null && selectedAmount! > 0
                    ? '\$${selectedAmount!.toStringAsFixed(2)}'
                    : '—',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Choose payment method', onPressed: onContinue),
      ],
    );
  }
}

class _MethodPanel extends StatelessWidget {
  const _MethodPanel({
    super.key,
    required this.methods,
    required this.selected,
    required this.onSelect,
    required this.amount,
    required this.onPay,
  });

  final List<String> methods;
  final String selected;
  final ValueChanged<String> onSelect;
  final double amount;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          'Pay \$${amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Select how you want to fund your wallet. This is a demo flow — no real charge is made.',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
        ),
        const SizedBox(height: 20),
        ...methods.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FinSurface(
              padding: EdgeInsets.zero,
              child: RadioListTile<String>(
                value: m,
                groupValue: selected,
                onChanged: (v) {
                  if (v != null) onSelect(v);
                },
                title: Text(m, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  m == 'Debit card'
                      ? 'Instant · Secured by FinPay'
                      : m == 'Bank transfer'
                          ? 'NIBSS-style routing (mock)'
                          : 'Wallet tokenized device pay',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                ),
                activeColor: AppColors.accent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Pay now', onPressed: onPay),
      ],
    );
  }
}

class _ProcessingPanel extends StatelessWidget {
  const _ProcessingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 52,
          height: 52,
          child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3),
        ),
        const SizedBox(height: 20),
        Text(
          'Connecting to payment gateway…',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: LinearProgressIndicator(
            minHeight: 6,
            backgroundColor: AppColors.border,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Authorizing with your bank in real time. Please wait.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
      ],
    );
  }
}
