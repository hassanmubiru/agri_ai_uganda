import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agri_ai_uganda/models/market_price.dart';

class MarketService {
  // Replace with your actual JSON data URL (e.g., GitHub Gist, S3, or API endpoint)
  // This is a placeholder URL that simulates a real endpoint structure.
  final String _dataUrl = "https://raw.githubusercontent.com/error51/agri-data/main/market_prices.json";

  Future<List<MarketPrice>> getMarketPrices() async {
    try {
      print("Fetching market prices from: $_dataUrl");
      final response = await http.get(Uri.parse(_dataUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) {
            // Mapping logic would go here
            // For now, we assume the JSON structure matches our model
            return MarketPrice(
                crop: json['crop'],
                currentPrice: json['currentPrice'],
                trend: json['trend'],
                history: (json['history'] as List).map((p) => PricePoint(p['day'], p['price'])).toList()
            );
        }).toList();
      }
    } catch (e) {
      print("Market Data Error (Using Offline Cache): $e");
    }

    // Fallback Data (Simulating Offline Cache)
    return [
      MarketPrice(
        crop: "Maize (Busoga)",
        currentPrice: 1250,
        trend: "up",
        history: [
          PricePoint(0, 1000),
          PricePoint(5, 1100),
          PricePoint(10, 1050),
          PricePoint(15, 1150),
          PricePoint(20, 1250),
        ],
      ),
      MarketPrice(
        crop: "Beans (Nambale)",
        currentPrice: 3600,
        trend: "down",
        history: [
          PricePoint(0, 4000),
          PricePoint(5, 3800),
          PricePoint(10, 3900),
          PricePoint(15, 3700),
          PricePoint(20, 3600),
        ],
      ),
       MarketPrice(
        crop: "Matooke (Bunch)",
        currentPrice: 25000,
        trend: "up",
        history: [
          PricePoint(0, 20000),
          PricePoint(5, 22000),
          PricePoint(10, 21000),
          PricePoint(15, 24000),
          PricePoint(20, 25000),
        ],
      ),
    ];
  }
}
