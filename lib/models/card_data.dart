class CardData {
  final String cardType;
  final int balance;
  final List<String>? raw;

  CardData({
    required this.cardType,
    required this.balance,
    this.raw,
  });
}