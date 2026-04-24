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

class _Biller {
  const _Biller({required this.id, required this.label, required this.icon, required this.hint});
  final String id;
  final String label;
  final IconData icon;
  final String hint;
}

enum _BillStep { category, details, review, processing }

class BillPayScreen extends StatefulWidget {
  const BillPayScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<BillPayScreen> createState() => _BillPayScreenState();
}

class _BillPayScreenState extends State<BillPayScreen> {
  static const _billers = [
    _Biller(id: 'airtime', label: 'Airtime & data', icon: Icons.smartphone, hint: 'Phone number'),
    _Biller(id: 'power', label: 'Electricity', icon: Icons.bolt, hint: 'Meter number'),
    _Biller(id: 'cable', label: 'Cable TV', icon: Icons.tv, hint: 'Smart card number'),
    _Biller(id: 'water', label: 'Water', icon: Icons.water_drop_outlined, hint: 'Account ID'),
    _Biller(id: 'internet', label: 'Internet', icon: Icons.wifi, hint: 'Subscriber ID'),
  ];

  _BillStep _step = _BillStep.category;
  _Biller? _biller;
  final _account = TextEditingController();
  String _amount = '';

  @override
  void dispose() {
    _account.dispose();
    super.dispose();
  }

  double? get _amountValue {
    final v = double.tryParse(_amount);
    if (v == null || v <= 0) return null;
    return v;
  }

  void _digit(String d) {
    setState(() {
      if (d == '.' && _amount.contains('.')) return;
      if (_amount == '0' && d != '.') {
        _amount = d;
      } else {
        _amount += d;
      }
    });
  }

  void _bs() {
    if (_amount.isEmpty) return;
    setState(() => _amount = _amount.substring(0, _amount.length - 1));
  }

  Future<void> _pay() async {
    final b = _biller;
    final a = _amountValue;
    if (b == null || a == null || _account.text.trim().isEmpty) return;
    setState(() => _step = _BillStep.processing);
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final wallet = context.read<WalletProvider>();
    final ref = wallet.recordSpend(
      amount: a,
      title: 'Bill pay · ${b.label}',
      category: TransactionCategory.other,
      merchant: b.label,
      notes: '${b.hint}: ${_account.text.trim()}',
      channel: 'Bill pay',
    );

    if (!mounted || ref.isEmpty) return;
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => PaymentReceiptScreen(
          headline: 'Bill payment successful',
          subtitle: 'Your biller will receive funds shortly.',
          amount: a,
          amountIsDebit: true,
          reference: ref,
          completedAt: DateTime.now(),
          rows: [
            ('Biller', b.label),
            (b.hint, _account.text.trim()),
            ('Fee', '\$0.00'),
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
              ModalSheetHeader(title: 'Bill pay', onClose: () => Navigator.of(context).maybePop()),
              if (_step != _BillStep.category && _step != _BillStep.processing)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_step == _BillStep.review) {
                          _step = _BillStep.details;
                        } else if (_step == _BillStep.details) {
                          _step = _BillStep.category;
                        }
                      });
                    },
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    label: const Text('Back'),
                  ),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _body(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case _BillStep.category:
        return ListView(
          key: const ValueKey('c'),
          children: [
            Text('What are you paying?', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            for (final b in _billers)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FinSurface(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(b.icon, color: AppColors.accent),
                    title: Text(b.label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => setState(() {
                      _biller = b;
                      _step = _BillStep.details;
                    }),
                  ),
                ),
              ),
          ],
        );
      case _BillStep.details:
        final b = _biller!;
        return ListView(
          key: const ValueKey('d'),
          children: [
            Text(b.label, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              controller: _account,
              keyboardType: TextInputType.text,
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: b.hint,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Amount', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              '\$${_amount.isEmpty ? '0' : _amount}',
              style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _MiniKeypad(onDigit: _digit, onBackspace: _bs),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Review payment',
              onPressed: _amountValue != null && _account.text.trim().isNotEmpty
                  ? () => setState(() => _step = _BillStep.review)
                  : null,
            ),
          ],
        );
      case _BillStep.review:
        final b = _biller!;
        final a = _amountValue!;
        return ListView(
          key: const ValueKey('r'),
          children: [
            FinSurface(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  _row('Biller', b.label),
                  const Divider(height: 1),
                  _row(b.hint, _account.text.trim()),
                  const Divider(height: 1),
                  _row('Amount', '\$${a.toStringAsFixed(2)}', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Pay bill', onPressed: _pay),
          ],
        );
      case _BillStep.processing:
        return Center(
          key: const ValueKey('p'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3),
              ),
              const SizedBox(height: 20),
              Text('Posting payment…', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
        );
    }
  }

  Widget _row(String k, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(k, style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          Text(
            v,
            style: GoogleFonts.poppins(fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _MiniKeypad extends StatelessWidget {
  const _MiniKeypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget k(String label, VoidCallback onTap) => InkWell(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(label, style: GoogleFonts.poppins(fontSize: 16)),
          ),
        );
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];
    return Column(
      children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final c in r) c == '⌫' ? k('⌫', onBackspace) : k(c, () => onDigit(c)),
              ],
            ),
          ),
      ],
    );
  }
}
