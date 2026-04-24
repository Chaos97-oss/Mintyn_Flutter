enum CardKind { physical, virtual }

class PaymentCardModel {
  const PaymentCardModel({
    required this.id,
    required this.kind,
    required this.lastFour,
    required this.holderName,
    required this.expiryLabel,
    required this.cvv,
  });

  final String id;
  final CardKind kind;
  final String lastFour;
  final String holderName;
  final String expiryLabel;
  final String cvv;
}
