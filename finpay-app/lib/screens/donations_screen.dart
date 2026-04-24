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

class _Charity {
  const _Charity({required this.name, required this.tag});
  final String name;
  final String tag;
}

enum _DonateStep { pick, amount, review, processing }

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  static const _orgs = [
    _Charity(name: 'Hope Children Fund', tag: 'Education'),
    _Charity(name: 'Clean Water Initiative', tag: 'Health'),
    _Charity(name: 'Local Food Bank', tag: 'Community'),
  ];

  _DonateStep _step = _DonateStep.pick;
  _Charity? _org;
  String _amount = '';
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  double? get _amt => double.tryParse(_amount);

  Future<void> _send() async {
    final o = _org;
    final a = _amt;
    if (o == null || a == null || a <= 0) return;
    setState(() => _step = _DonateStep.processing);
    await Future<void>.delayed(const Duration(milliseconds: 1900));
    if (!mounted) return;

    final wallet = context.read<WalletProvider>();
    final ref = wallet.recordSpend(
      amount: a,
      title: 'Donation · ${o.name}',
      category: TransactionCategory.other,
      merchant: o.name,
      notes: _message.text.trim(),
      channel: 'Donations',
    );

    if (!mounted || ref.isEmpty) return;
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => PaymentReceiptScreen(
          headline: 'Donation sent',
          subtitle: 'Thank you for supporting ${o.name}.',
          amount: a,
          amountIsDebit: true,
          reference: ref,
          completedAt: DateTime.now(),
          rows: [
            ('Organization', o.name),
            ('Focus', o.tag),
            if (_message.text.trim().isNotEmpty) ('Message', _message.text.trim()),
          ],
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
            children: [
              ModalSheetHeader(title: 'Donations', onClose: () => Navigator.of(context).maybePop()),
              if (_step != _DonateStep.pick && _step != _DonateStep.processing)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_step == _DonateStep.review) {
                          _step = _DonateStep.amount;
                        } else if (_step == _DonateStep.amount) {
                          _step = _DonateStep.pick;
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
      case _DonateStep.pick:
        return ListView(
          key: const ValueKey('p'),
          children: [
            Text('Support a cause', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            for (final o in _orgs)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FinSurface(
                  child: ListTile(
                    title: Text(o.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text(o.tag, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.favorite_outline, color: AppColors.accent),
                    onTap: () => setState(() {
                      _org = o;
                      _step = _DonateStep.amount;
                    }),
                  ),
                ),
              ),
          ],
        );
      case _DonateStep.amount:
        return ListView(
          key: const ValueKey('a'),
          children: [
            Text(_org!.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _message,
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Add a message (optional)',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Amount (\$)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => setState(() => _amount = v),
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Review donation',
              onPressed: (_amt != null && _amt! > 0) ? () => setState(() => _step = _DonateStep.review) : null,
            ),
          ],
        );
      case _DonateStep.review:
        final o = _org!;
        final a = _amt!;
        return ListView(
          key: const ValueKey('r'),
          children: [
            FinSurface(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  _r('Organization', o.name),
                  const Divider(height: 1),
                  _r('Amount', '\$${a.toStringAsFixed(2)}', bold: true),
                  if (_message.text.trim().isNotEmpty) ...[
                    const Divider(height: 1),
                    _r('Message', _message.text.trim()),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Donate now', onPressed: _send),
          ],
        );
      case _DonateStep.processing:
        return Center(
          key: const ValueKey('pr'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 20),
              Text('Processing donation…', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
        );
    }
  }

  Widget _r(String k, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(k, style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
