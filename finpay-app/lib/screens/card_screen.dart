import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/payment_card_model.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/payment_card.dart';
import '../widgets/screen_labels.dart';
import '../widgets/settings_row.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key, required this.onOpenCardTransactions});

  final VoidCallback onOpenCardTransactions;

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _flipCtrl;

  bool _pin = true;
  bool _qr = true;
  bool _online = false;
  bool _tap = true;
  int _page = 0;

  bool _reveal = false;
  bool _frozen = false;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _pageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleKind(WalletProvider wallet, CardKind next) {
    if (wallet.activeCardKind == next) return;
    wallet.setActiveCardKind(next);
    setState(() {
      _page = 0;
      _reveal = false;
      _flipCtrl.value = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  Future<void> _toggleFlip() async {
    if (_flipCtrl.value < 0.5) {
      await _flipCtrl.forward();
    } else {
      await _flipCtrl.reverse();
    }
  }

  void _onReveal() {
    setState(() => _reveal = !_reveal);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
      backgroundColor: AppColors.green,
        content: Text(_reveal ? 'Sensitive details visible' : 'Details masked'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onFreeze() {
    setState(() => _frozen = !_frozen);
  }

  void _onLock() {
    setState(() => _locked = !_locked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
      backgroundColor: AppColors.green,
        content: Text(_locked ? 'Card locked for new purchases' : 'Card unlocked'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _flipCard(PaymentCardModel card) {
    return AnimatedBuilder(
      animation: _flipCtrl,
      builder: (context, _) {
        // Full 0→π rotation; back face gets an extra π so text stays LTR-readable (not mirrored).
        final angle = _flipCtrl.value * math.pi;
        final showFront = angle < math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: showFront
              ? PaymentCardFront(
                  card: card,
                  padding: 20,
                  revealPan: _reveal,
                  revealCvv: _reveal,
                  isFrozen: _frozen,
                )
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: PaymentCardBack(card: card, padding: 20),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final cards = wallet.cardsForKind(wallet.activeCardKind);
    final page = _pageController.hasClients ? (_pageController.page ?? _page.toDouble()) : _page.toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Card',
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '2 Physical Card, 1 Virtual Card',
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
              ],
            ),
            const SizedBox(height: 16),
            _KindToggle(
              physicalSelected: wallet.activeCardKind == CardKind.physical,
              onPhysical: () => _toggleKind(wallet, CardKind.physical),
              onVirtual: () => _toggleKind(wallet, CardKind.virtual),
            ),
            const SizedBox(height: 18),
            if (cards.isEmpty)
              const SizedBox.shrink()
            else
              Column(
                children: [
                  SizedBox(
                    height: (MediaQuery.sizeOf(context).width * 0.82) / 1.6 + 12,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: cards.length,
                      onPageChanged: (i) {
                        setState(() {
                          _page = i;
                          _flipCtrl.value = 0;
                          _reveal = false;
                        });
                      },
                      itemBuilder: (context, i) {
                        final dist = (page - i).abs();
                        // Center page at full scale; adjacent cards shrink for depth.
                        final scale = (1.0 - 0.16 * dist.clamp(0.0, 2.0)).clamp(0.76, 1.0);
                        final opacity = (1.0 - 0.28 * dist.clamp(0.0, 1.5)).clamp(0.48, 1.0);
                        final isActive = i == _page;
                        return Center(
                          child: Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                child: isActive
                                    ? GestureDetector(
                                        onDoubleTap: _toggleFlip,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _flipCard(cards[i]),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Double-tap card to flip',
                                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                                            ),
                                          ],
                                        ),
                                      )
                                    : PaymentCardFront(
                                        card: cards[i],
                                        padding: 20,
                                        revealPan: false,
                                        revealCvv: false,
                                        isFrozen: _frozen,
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(cards.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 18 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active ? AppColors.accent : AppColors.textMuted,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CardAction(
                  icon: Icons.ac_unit,
                  label: 'Freeze Card',
                  active: _frozen,
                  onTap: _onFreeze,
                ),
                _CardAction(
                  icon: _reveal ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  label: 'Reveal Details',
                  active: _reveal,
                  onTap: _onReveal,
                ),
                _CardAction(
                  icon: Icons.lock_outline,
                  label: 'Lock Card',
                  active: _locked,
                  onTap: _onLock,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Card Settings',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SettingsToggleRow(
                    icon: Icons.pin_outlined,
                    label: 'Change Pin',
                    value: _pin,
                    onChanged: (v) => setState(() => _pin = v),
                  ),
                  const Divider(height: 1),
                  SettingsToggleRow(
                    icon: Icons.qr_code_2,
                    label: 'QR Payment',
                    value: _qr,
                    onChanged: (v) => setState(() => _qr = v),
                  ),
                  const Divider(height: 1),
                  SettingsToggleRow(
                    icon: Icons.storefront_outlined,
                    label: 'Online Shopping',
                    value: _online,
                    onChanged: (v) => setState(() => _online = v),
                  ),
                  const Divider(height: 1),
                  SettingsNavRow(
                    icon: Icons.style_outlined,
                    label: 'Card Transactions',
                    onTap: widget.onOpenCardTransactions,
                  ),
                  const Divider(height: 1),
                  SettingsToggleRow(
                    icon: Icons.contactless_outlined,
                    label: 'Tap Pay',
                    value: _tap,
                    onChanged: (v) => setState(() => _tap = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KindToggle extends StatelessWidget {
  const _KindToggle({
    required this.physicalSelected,
    required this.onPhysical,
    required this.onVirtual,
  });

  final bool physicalSelected;
  final VoidCallback onPhysical;
  final VoidCallback onVirtual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                // color: AppColors.background,
                color: !physicalSelected ? AppColors.card : AppColors.background,
                borderRadius: BorderRadius.circular(999),
                // border: Border.all(color: physicalSelected ? AppColors.accent : Colors.transparent, width: 1.5),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onPhysical,
                child: Center(
                  child: Text(
                    'Physical Card',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: physicalSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: physicalSelected ? AppColors.card : AppColors.background,
                borderRadius: BorderRadius.circular(999),
                // border: Border.all(color: !physicalSelected ? AppColors.accent : Colors.transparent, width: 1.5),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onVirtual,
                child: Center(
                  child: Text(
                    'Virtual Card',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: !physicalSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatefulWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  State<_CardAction> createState() => _CardActionState();
}

class _CardActionState extends State<_CardAction> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.elasticOut,
        scale: _scale,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: widget.active ? AppColors.accent.withValues(alpha: 0.25) : AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: widget.active ? AppColors.accent : AppColors.border, width: widget.active ? 2 : 1),
              ),
              child: Icon(widget.icon, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
