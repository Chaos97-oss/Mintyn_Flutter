import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/payment_card_model.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Front of the card (PAN, CVV area, chip).
class PaymentCardFront extends StatelessWidget {
  const PaymentCardFront({
    super.key,
    required this.card,
    this.padding = 20,
    this.revealPan = false,
    this.revealCvv = false,
    this.isFrozen = false,
  });

  final PaymentCardModel card;
  final double padding;
  final bool revealPan;
  final bool revealCvv;
  final bool isFrozen;

  String get _panLine {
    if (revealPan) {
      return '5163 1234 5678 ${card.lastFour}';
    }
    return '•••• •••• •••• ${card.lastFour}';
  }

  String get _cvvLine => revealCvv ? card.cvv : '•••';

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.cardBackground,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(gradient: AppColors.paymentCardGradient),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.cardChip,
                        height: 34,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 10),
                      // Icon(Icons.contactless, color: Colors.white.withValues(alpha: 0.95), size: 26),
                      const Spacer(),
                      Image.asset(
                        AppAssets.mastercardPng,
                        height: 34,
                        errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _panLine,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: revealPan ? 1.2 : 2,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Card Holder',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              card.holderName,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valid',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                          ),
                          Text(
                            card.expiryLabel.replaceAll('/', ' / '),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CVV',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                          ),
                          Text(
                            _cvvLine,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isFrozen)
              Positioned.fill(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.ac_unit, color: Colors.white, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        'Card frozen',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Back of the card (magnetic stripe, support info).
class PaymentCardBack extends StatelessWidget {
  const PaymentCardBack({super.key, required this.card, this.padding = 20});

  final PaymentCardModel card;
  final double padding;

  @override
  Widget build(BuildContext context) {
    // Card back must read left-to-right regardless of app locale (avoids mirrored / RTL layout on flip).
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AspectRatio(
        aspectRatio: 1.6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: ColoredBox(
            color: const Color(0xFF121214),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Container(
                    height: 38,
                    width: double.infinity,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.92),
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(
                          child: Text(
                            'Authorized signature',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ),
                        Text(
                          card.holderName,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Customer service: 1-800-FINPAY',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This card remains property of FinPay Bank. Use subject to agreement.',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Non-interactive preview (e.g. card transaction header).
class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.card,
    this.flipAngle = 0,
    this.padding = 18,
  });

  final PaymentCardModel card;
  final double flipAngle;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(flipAngle),
      child: PaymentCardFront(card: card, padding: padding),
    );
  }
}
