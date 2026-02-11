import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:agri_ai_uganda/services/market_service.dart';
import 'package:agri_ai_uganda/models/market_price.dart';
import 'package:agri_ai_uganda/utils/constants.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _marketService = MarketService();
  List<MarketPrice> _prices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final prices = await _marketService.getMarketPrices();
    if(mounted) {
      setState(() {
        _prices = prices;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market Prices')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _prices.length,
              itemBuilder: (context, index) {
                final price = _prices[index];
                return _buildPriceCard(price);
              },
            ),
    );
  }

  Widget _buildPriceCard(MarketPrice price) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price.crop,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "UGX ${price.currentPrice}/kg",
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                _buildTrendIcon(price.trend),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: charts.LineChart(
                _createChartData(price.history),
                animate: true,
                domainAxis: const charts.NumericAxisSpec(
                  renderSpec: charts.NoneRenderSpec(),
                ),
              ),
            ),
            if (price.trend == "up")
                Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    color: Colors.green[50],
                    child: const Row(
                        children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            SizedBox(width: 8),
                            Text("Good time to sell!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                        ]
                    )
                )
          ],
        ),
      ),
    );
  }

  List<charts.Series<PricePoint, int>> _createChartData(List<PricePoint> data) {
    return [
      charts.Series<PricePoint, int>(
        id: 'Price',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (PricePoint p, _) => p.day,
        measureFn: (PricePoint p, _) => p.price,
        data: data,
      )
    ];
  }

  Widget _buildTrendIcon(String trend) {
     IconData icon;
     Color color;
     
     if (trend == "up") {
         icon = Icons.trending_up;
         color = Colors.green;
     } else if (trend == "down") {
         icon = Icons.trending_down;
         color = Colors.red;
     } else {
         icon = Icons.trending_flat;
         color = Colors.grey;
     }
     
     return Container(
         padding: const EdgeInsets.all(8),
         decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
         child: Icon(icon, color: color),
     );
  }
}
