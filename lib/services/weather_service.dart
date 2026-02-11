import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  // Placeholder API Key - In production, use env variables
  final String apiKey = "YOUR_OPENWEATHERMAP_API_KEY";
  final String baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> getLocalWeather() async {
    try {
      Position position = await _determinePosition();
      
      // MOCK RESPONSE for demo purposes (to avoid invalid API key error)
      // In real app:
      /*
      final response = await http.get(Uri.parse(
          '$baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      */
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        "name": "Kampala",
        "main": {"temp": 26.5, "humidity": 60},
        "weather": [{"description": "scattered clouds", "icon": "03d"}]
      };
    } catch (e) {
      print("Weather Error: $e");
      // Return fallback data
      return {
        "name": "Local Area",
        "main": {"temp": 25.0, "humidity": 50},
        "weather": [{"description": "clear sky", "icon": "01d"}]
      };
    }
  }
}
