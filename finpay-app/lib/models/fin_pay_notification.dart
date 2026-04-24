enum FinPayNotificationKind { security, payment, promo, account }

class FinPayNotification {
  const FinPayNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.kind,
    this.read = false,
    this.detailTitle,
    this.detailParagraph,
    this.detailBullets = const [],
    this.referenceId,
    this.actionHint,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final FinPayNotificationKind kind;
  final bool read;

  /// Optional richer headline inside the detail sheet.
  final String? detailTitle;

  /// Longer explanation for the bottom sheet.
  final String? detailParagraph;

  final List<String> detailBullets;
  final String? referenceId;
  final String? actionHint;

  FinPayNotification copyWith({
    bool? read,
  }) {
    return FinPayNotification(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      kind: kind,
      read: read ?? this.read,
      detailTitle: detailTitle,
      detailParagraph: detailParagraph,
      detailBullets: detailBullets,
      referenceId: referenceId,
      actionHint: actionHint,
    );
  }
}
