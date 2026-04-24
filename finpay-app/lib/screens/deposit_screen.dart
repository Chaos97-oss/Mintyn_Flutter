import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/fin_surface.dart';
import '../widgets/modal_sheet_header.dart';
import '../widgets/primary_button.dart';
import 'payment_receipt_screen.dart';

enum _DepStep { intro, amount, review, processing }

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  _DepStep _step = _DepStep.intro;
  String _source = 'Bank transfer';
  final _reference = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _reference.dispose();
    _amount.dispose();
    super.dispose();
  }

  double? get _amt => double.tryParse(_amount.text.trim());

  Future<void> _submit() async {
    final a = _amt;
    if (a == null || a <= 0) return;
    setState(() => _step = _DepStep.processing);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 2100));
      if (!mounted) return;

      final wallet = context.read<WalletProvider>();
      final ref = wallet.recordReceive(
        amount: a,
        title: 'Deposit · $_source',
        category: TransactionCategory.wallet,
        merchant: 'FinPay Clearing',
        notes: _reference.text.trim().isEmpty ? 'Instant credit' : 'Ref: ${_reference.text.trim()}',
        channel: _source,
      );

      if (!mounted || ref.isEmpty) {
        if (mounted) setState(() => _step = _DepStep.review);
        return;
      }

      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          builder: (ctx) => PaymentReceiptScreen(
            headline: 'Deposit received',
            subtitle: 'Your wallet has been credited.',
            amount: a,
            amountIsDebit: false,
            reference: ref,
            completedAt: DateTime.now(),
            rows: [
              ('Channel', _source),
              if (_reference.text.trim().isNotEmpty) ('Bank reference', _reference.text.trim()),
              ('Settlement', 'Instant'),
            ],
          ),
        ),
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      widget.onCompleted?.call();
    } catch (e) {
      if (mounted) {
        setState(() => _step = _DepStep.review);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deposit could not finish: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              ModalSheetHeader(title: 'Deposit', onClose: () => Navigator.of(context).maybePop()),
              if (_step != _DepStep.intro && _step != _DepStep.processing)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_step == _DepStep.review) {
                          _step = _DepStep.amount;
                        } else if (_step == _DepStep.amount) {
                          _step = _DepStep.intro;
                        }
                      });
                    },
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    label: const Text('Back'),
                  ),
                ),
              Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: _body())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case _DepStep.intro:
        return ListView(
          key: const ValueKey('i'),
          children: [
            Text(
              'Add money to FinPay',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Simulate a bank transfer or card funding that credits your wallet instantly.',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            FinSurface(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Bank transfer'),
                    subtitle: Text('Use a virtual account / NIBSS mock', style: GoogleFonts.poppins(fontSize: 11)),
                    value: 'Bank transfer',
                    groupValue: _source,
                    onChanged: (v) => setState(() => _source = v!),
                    activeColor: AppColors.accent,
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Debit card'),
                    subtitle: Text('Instant authorization', style: GoogleFonts.poppins(fontSize: 11)),
                    value: 'Debit card',
                    groupValue: _source,
                    onChanged: (v) => setState(() => _source = v!),
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Continue', onPressed: () => setState(() => _step = _DepStep.amount)),
          ],
        );
      case _DepStep.amount:
        return ListView(
          key: const ValueKey('a'),
          children: [
            Text('Amount', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.poppins(fontSize: 24, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Deposit amount',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reference,
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Bank reference (optional)',
                hintText: 'e.g. TRF-88321',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Review deposit',
              onPressed: (_amt != null && _amt! > 0)
                  ? () {
                      final parsed = _amt;
                      if (parsed == null || parsed <= 0) return;
                      setState(() => _step = _DepStep.review);
                    }
                  : null,
            ),
          ],
        );
      case _DepStep.review:
        final reviewAmount = _amt;
        if (reviewAmount == null || reviewAmount <= 0) {
          return ListView(
            key: const ValueKey('r-invalid'),
            children: [
              Text(
                'Enter a valid deposit amount to continue.',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Back to amount',
                onPressed: () => setState(() => _step = _DepStep.amount),
              ),
            ],
          );
        }
        return _reviewBody(reviewAmount);
      case _DepStep.processing:
        return Center(
          key: const ValueKey('p'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 20),
              Text(
                'Confirming with your bank…',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
    }
  }

  Widget _reviewBody(double reviewAmount) {
    return ListView(
      key: const ValueKey('r'),
      children: [
        FinSurface(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _rw('Channel', _source),
              const Divider(height: 1),
              _rw('Amount', '\$${reviewAmount.toStringAsFixed(2)}', bold: true),
              if (_reference.text.trim().isNotEmpty) ...[
                const Divider(height: 1),
                _rw('Reference', _reference.text.trim()),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Confirm deposit', onPressed: _submit),
      ],
    );
  }

  Widget _rw(String k, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(k, style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          Text(v, style: GoogleFonts.poppins(fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
