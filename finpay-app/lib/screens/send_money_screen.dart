import 'package:flutter/material.dart';
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

class _Contact {
  const _Contact({required this.name, required this.detail, required this.bank});
  final String name;
  final String detail;
  final String bank;
}

enum _SendStep { chooseRecipient, amountAndNote, review, processing }

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  static const _contacts = [
    _Contact(name: 'Ava Chen', detail: '•••• 8012', bank: 'FinPay Bank'),
    _Contact(name: 'Leo Park', detail: '•••• 4401', bank: 'Metro Credit'),
    _Contact(name: 'Mia Rossi', detail: '•••• 9920', bank: 'Union Savings'),
    _Contact(name: 'Noah Ade', detail: '•••• 1188', bank: 'FinPay Bank'),
  ];

  _SendStep _step = _SendStep.chooseRecipient;
  int? _selectedContactIndex;
  final _note = TextEditingController();
  String _amount = '';

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  _Contact? get _recipient =>
      _selectedContactIndex != null ? _contacts[_selectedContactIndex!] : null;

  void _tapDigit(String d) {
    if (_step != _SendStep.amountAndNote) return;
    setState(() {
      if (d == '.' && _amount.contains('.')) return;
      if (_amount == '0' && d != '.') {
        _amount = d;
      } else {
        _amount += d;
      }
    });
  }

  void _backspace() {
    if (_amount.isEmpty) return;
    setState(() => _amount = _amount.substring(0, _amount.length - 1));
  }

  double? get _amountValue {
    final v = double.tryParse(_amount);
    if (v == null || v <= 0) return null;
    return v;
  }

  Future<void> _confirmAndSend() async {
    final recipient = _recipient;
    final amount = _amountValue;
    if (recipient == null || amount == null) return;

    setState(() => _step = _SendStep.processing);
    await Future<void>.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;
    final wallet = context.read<WalletProvider>();
    final ref = wallet.recordSpend(
      amount: amount,
      title: 'Transfer · ${recipient.name}',
      category: TransactionCategory.other,
      merchant: recipient.name,
      notes: _note.text.trim(),
      channel: 'Wallet · ${recipient.bank}',
    );

    if (!mounted || ref.isEmpty) return;
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => PaymentReceiptScreen(
          headline: 'Transfer successful',
          subtitle: 'Money was sent from your FinPay wallet.',
          amount: amount,
          amountIsDebit: true,
          reference: ref,
          completedAt: DateTime.now(),
          rows: [
            ('Recipient', recipient.name),
            ('Account', recipient.detail),
            ('Bank', recipient.bank),
            if (_note.text.trim().isNotEmpty) ('Note', _note.text.trim()),
            ('Fee', '\$0.00'),
          ],
          footerNote: 'A debit alert has been added to your transaction history.',
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
            ModalSheetHeader(
              title: 'Send money',
              onClose: () => Navigator.of(context).maybePop(),
            ),
            if (_step != _SendStep.chooseRecipient && _step != _SendStep.processing)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_step == _SendStep.review) {
                        _step = _SendStep.amountAndNote;
                      } else if (_step == _SendStep.amountAndNote) {
                        _step = _SendStep.chooseRecipient;
                      }
                    });
                  },
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  label: const Text('Back'),
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _buildStepBody(),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case _SendStep.chooseRecipient:
        return _RecipientStep(
          key: const ValueKey('r'),
          contacts: _contacts,
          selected: _selectedContactIndex,
          onSelect: (i) => setState(() => _selectedContactIndex = i),
          onContinue: _selectedContactIndex == null
              ? null
              : () => setState(() => _step = _SendStep.amountAndNote),
        );
      case _SendStep.amountAndNote:
        return _AmountStep(
          key: const ValueKey('a'),
          amount: _amount,
          note: _note,
          onDigit: _tapDigit,
          onBackspace: _backspace,
          onContinue: _amountValue == null
              ? null
              : () => setState(() => _step = _SendStep.review),
        );
      case _SendStep.review:
        final r = _recipient!;
        final a = _amountValue!;
        return _ReviewStep(
          key: const ValueKey('v'),
          recipient: r,
          amount: a,
          note: _note.text.trim(),
          onConfirm: _confirmAndSend,
        );
      case _SendStep.processing:
        return _ProcessingStep(key: const ValueKey('p'));
    }
  }
}

class _RecipientStep extends StatelessWidget {
  const _RecipientStep({
    super.key,
    required this.contacts,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
  });

  final List<_Contact> contacts;
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      children: [
        Text(
          'Send to',
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a recipient',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...List.generate(contacts.length, (i) {
          final c = contacts[i];
          final sel = selected == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FinSurface(
              padding: EdgeInsets.zero,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: () => onSelect(i),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.overlayScrim,
                        child: Text(c.name[0], style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            Text(
                              '${c.detail} · ${c.bank}',
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        sel ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: sel ? AppColors.accent : AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        PrimaryButton(label: 'Continue', onPressed: onContinue),
      ],
    );
  }
}

class _AmountStep extends StatelessWidget {
  const _AmountStep({
    super.key,
    required this.amount,
    required this.note,
    required this.onDigit,
    required this.onBackspace,
    required this.onContinue,
  });

  final String amount;
  final TextEditingController note;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          'Amount',
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('\$', style: GoogleFonts.poppins(fontSize: 36, color: AppColors.textSecondary)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                amount.isEmpty ? '0' : amount,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: AppColors.border),
        const SizedBox(height: 16),
        _Keypad(onDigit: onDigit, onBackspace: onBackspace),
        const SizedBox(height: 16),
        TextField(
          controller: note,
          style: GoogleFonts.poppins(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Add a note (optional)',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Review transfer', onPressed: onContinue),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    super.key,
    required this.recipient,
    required this.amount,
    required this.note,
    required this.onConfirm,
  });

  final _Contact recipient;
  final double amount;
  final String note;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          'Review',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        FinSurface(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              _row('Recipient', recipient.name),
              const Divider(height: 1),
              _row('Account', recipient.detail),
              const Divider(height: 1),
              _row('Bank', recipient.bank),
              const Divider(height: 1),
              _row('You send', '\$${amount.toStringAsFixed(2)}', bold: true),
              const Divider(height: 1),
              _row('Fee', '\$0.00'),
              if (note.isNotEmpty) ...[
                const Divider(height: 1),
                _row('Note', note),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'By continuing you authorize FinPay to debit your wallet for this transfer.',
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted, height: 1.35),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Confirm & send', onPressed: onConfirm),
      ],
    );
  }

  Widget _row(String k, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(k, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Text(
            v,
            style: GoogleFonts.poppins(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingStep extends StatelessWidget {
  const _ProcessingStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.accent),
          const SizedBox(height: 24),
          Text(
            'Processing transfer…',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Please keep this screen open.',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(label, style: GoogleFonts.poppins(fontSize: 20, color: AppColors.textPrimary)),
        ),
      );
    }

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
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final c in r)
                  c == '⌫' ? key('⌫', onBackspace) : key(c, () => onDigit(c)),
              ],
            ),
          ),
      ],
    );
  }
}
