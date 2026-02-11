import 'package:agri_ai_uganda/models/market_price.dart';

class MarketService {
  Future<List<MarketPrice>> getMarketPrices() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return [
      MarketPrice(
        crop: "Maize",
        currentPrice: 1200,
        trend: "up",
        history: [
          PricePoint(0, 1000),
          PricePoint(5, 1100),
          PricePoint(10, 1050),
          PricePoint(15, 1150),
          PricePoint(20, 1200),
        ],
      ),
      MarketPrice(
        crop: "Beans (Nambale)",
        currentPrice: 3500,
        trend: "down",
        history: [
          PricePoint(0, 4000),
          PricePoint(5, 3800),
          PricePoint(10, 3900),
          PricePoint(15, 3600),
          PricePoint(20, 3500),
        ],
      ),
      MarketPrice(
        crop: "Cassava Flour",
        currentPrice: 2000,
        trend: "stable",
        history: [
          PricePoint(0, 2000),
          PricePoint(5, 1950),
          PricePoint(10, 2050),
          PricePoint(15, 2000),
          PricePoint(20, 2000),
        ],
      ),
      MarketPrice(
        crop: "Coffee (Robusta)",
        currentPrice: 8500,
        trend: "up",
        history: [
          PricePoint(0, 8000),
          PricePoint(5, 8200),
          PricePoint(10, 8100),
          PricePoint(15, 8400),
          PricePoint(20, 8500),
        ],
      ),
    ];
  }
}
