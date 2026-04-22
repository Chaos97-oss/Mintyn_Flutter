enum CardType { physical, virtual }

class CardSettings {
  final bool changePin;
  final bool qrPayment;
  final bool onlineShopping;
  final bool tapPay;

  const CardSettings({
    this.changePin = true,
    this.qrPayment = true,
    this.onlineShopping = false,
    this.tapPay = true,
  });
}

class CardModel {
  final String id;
  final CardType type;
  final String cardNumber; // e.g., '•••• •••• •••• 3466'
  final String cardHolder;
  final String validThru; // e.g., '12 / 02 / 2024'
  final String cvv;
  final bool isFrozen;
  final CardSettings settings;

  const CardModel({
    required this.id,
    required this.type,
    required this.cardNumber,
    required this.cardHolder,
    required this.validThru,
    required this.cvv,
    this.isFrozen = false,
    this.settings = const CardSettings(),
  });
}
