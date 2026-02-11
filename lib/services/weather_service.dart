import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  // API Key provided by user
  final String apiKey = "c6a42b45fc61acb4187fab541418a0ed";
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
      
      final url = '$baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';
      print("Fetching weather from: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      print("Weather Error: $e");
      // Return fallback data only on error
      return {
        "name": "Error",
        "main": {"temp": 0.0, "humidity": 0},
        "weather": [{"description": "unknown", "icon": "01d"}]
      };
    }
  }
}
