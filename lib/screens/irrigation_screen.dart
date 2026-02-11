import 'package:flutter/material.dart';
import 'package:agri_ai_uganda/services/weather_service.dart';
import 'package:agri_ai_uganda/models/irrigation_plan.dart';
import 'package:agri_ai_uganda/utils/constants.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cropController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  String _selectedSoil = 'Loam';
  
  final List<String> _soilTypes = ['Loam', 'Clay', 'Sandy', 'Silt'];
  final WeatherService _weatherService = WeatherService();
  
  IrrigationPlan? _plan;
  bool _isLoading = false;
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final data = await _weatherService.getLocalWeather();
    if(mounted) {
        setState(() => _weatherData = data);
    }
  }

  void _generatePlan() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate logic based on inputs and weather
      // Real logic would be more complex
      Future.delayed(const Duration(seconds: 1), () {
        if(!mounted) return;
        
        String freq = "Every 2 days";
        String amt = "Standard";
        List<String> tips = ["Mulch your garden to retain moisture."];
        
        if (_selectedSoil == 'Sandy') {
            freq = "Daily (Morning)";
            tips.add("Sandy soil drains fast, water frequently.");
        } else if (_selectedSoil == 'Clay') {
            freq = "Every 3-4 days";
            tips.add("Clay holds water, avoid waterlogging.");
        }

        if (_weatherData != null && (_weatherData!['main']['temp'] ?? 25) > 30) {
            freq = "Daily (Late Evening)";
            tips.add("It's hot! Water in the evening to reduce evaporation.");
        }
        
        setState(() {
          _plan = IrrigationPlan(
            cropType: _cropController.text,
            soilType: _selectedSoil,
            farmSize: double.tryParse(_sizeController.text) ?? 1.0,
            frequency: freq,
            amount: "Apply until soil is moist",
            tips: tips
          );
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Irrigation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Weather Card
            if (_weatherData != null)
              Card(
                color: AppColors.primaryGreen.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                       const Icon(Icons.cloud, size: 40, color: AppColors.primaryGreen),
                       const SizedBox(width: 16),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("Weather in ${_weatherData!['name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                           Text("${_weatherData!['main']['temp']}°C, ${_weatherData!['weather'][0]['description']}"),
                         ],
                       )
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            
            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _cropController,
                    decoration: const InputDecoration(labelText: 'Crop Type (e.g., Maize)', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Enter crop name' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSoil,
                    decoration: const InputDecoration(labelText: 'Soil Type', border: OutlineInputBorder()),
                    items: _soilTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedSoil = val!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sizeController,
                    decoration: const InputDecoration(labelText: 'Farm Size (Acres)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter size' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _generatePlan,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50)
                    ),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Get Recommendations', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Results
            if (_plan != null) ...[
                const Divider(),
                Text("Your Watering Schedule", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.darkBrown, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                 _buildInfoRow(Icons.calendar_today, "Frequency", _plan!.frequency),
                 _buildInfoRow(Icons.water_drop, "Amount", _plan!.amount),
                 const SizedBox(height: 16),
                 const Text("Tips:", style: TextStyle(fontWeight: FontWeight.bold)),
                 ..._plan!.tips.map((t) => Padding(
                     padding: const EdgeInsets.only(top: 4.0),
                     child: Text("• $t"),
                 )),
            ]
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(label, style: const TextStyle(color: Colors.grey)),
               Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
             ],
          )
        ],
      ),
    );
  }
}
