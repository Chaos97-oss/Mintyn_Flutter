import '../models/fin_pay_notification.dart';

List<FinPayNotification> mockFinPayNotifications() {
  final now = DateTime.now();
  return [
    FinPayNotification(
      id: 'n1',
      title: 'Login from a new device',
      body: 'We noticed a sign-in to FinPay from Chrome on macOS in Lagos.',
      timestamp: now.subtract(const Duration(minutes: 12)),
      kind: FinPayNotificationKind.security,
      read: false,
      detailTitle: 'Security alert',
      detailParagraph:
          'If this was you, no action is needed. If you do not recognize this activity, secure your account immediately by changing your password and enabling biometric login in Settings.',
      detailBullets: const [
        'Device: Chrome on macOS',
        'Approximate location: Lagos, NG',
        'Time: within the last hour',
      ],
      referenceId: 'SEC-${now.millisecondsSinceEpoch}',
      actionHint: 'Not you? Tap Support in Settings.',
    ),
    FinPayNotification(
      id: 'n2',
      title: 'Transfer completed',
      body: 'Your transfer of \$120.00 to MetroRide was successful.',
      timestamp: now.subtract(const Duration(hours: 2)),
      kind: FinPayNotificationKind.payment,
      read: false,
      detailTitle: 'Payment receipt',
      detailParagraph: 'Funds have been debited from your FinPay wallet and delivered to the recipient.',
      detailBullets: const [
        'Recipient: MetroRide',
        'Channel: Wallet transfer',
        'Status: Successful',
      ],
      referenceId: 'FP-TX-884221',
    ),
    FinPayNotification(
      id: 'n3',
      title: 'Cashback earned',
      body: 'You earned \$2.50 cashback on eligible card spend this week.',
      timestamp: now.subtract(const Duration(hours: 8)),
      kind: FinPayNotificationKind.promo,
      read: true,
      detailTitle: 'Rewards update',
      detailParagraph: 'Cashback is credited to your wallet automatically when promotions apply.',
      detailBullets: const [
        'Campaign: Everyday spend Q2',
        'Next payout: end of week',
      ],
      referenceId: 'CB-99201',
    ),
    FinPayNotification(
      id: 'n4',
      title: 'Bill payment reminder',
      body: 'Your electricity bill for City Utilities is due in 3 days.',
      timestamp: now.subtract(const Duration(hours: 27)),
      kind: FinPayNotificationKind.account,
      read: false,
      detailTitle: 'Upcoming bill',
      detailParagraph: 'Pay early to avoid service interruption. You can pay in one tap from Bill Pay on your dashboard.',
      detailBullets: const [
        'Biller: City Utilities',
        'Suggested amount: \$89.20',
      ],
      referenceId: 'BPAY-REM-441',
      actionHint: 'Open Bill Pay from the home screen.',
    ),
    FinPayNotification(
      id: 'n5',
      title: 'Statement ready',
      body: 'Your March e-statement is available to view or download.',
      timestamp: now.subtract(const Duration(days: 2)),
      kind: FinPayNotificationKind.account,
      read: true,
      detailTitle: 'E-Statement',
      detailParagraph: 'Statements include all wallet and card activity for the period.',
      detailBullets: const [
        'Format: PDF',
        'Retention: 24 months in-app',
      ],
      referenceId: 'EST-MAR-2026',
    ),
    FinPayNotification(
      id: 'n6',
      title: 'Card frozen',
      body: 'Your physical card ending in 3466 was temporarily frozen from the Cards tab.',
      timestamp: now.subtract(const Duration(days: 3)),
      kind: FinPayNotificationKind.security,
      read: true,
      detailTitle: 'Card status',
      detailParagraph: 'While frozen, new purchases are blocked. In-person settings and transfers from your wallet are unchanged.',
      detailBullets: const [
        'Card: •••• 3466',
        'Action: Freeze toggle',
      ],
      referenceId: 'CARD-FRZ-221',
    ),
  ];
}
