class MarketPrice {
  final String crop;
  final int currentPrice; // UGX per kg
  final String trend; // "up", "down", "stable"
  final List<PricePoint> history;

  MarketPrice({
    required this.crop,
    required this.currentPrice,
    required this.trend,
    required this.history,
  });
}

class PricePoint {
  final int day;
  final int price;

  PricePoint(this.day, this.price);
}
