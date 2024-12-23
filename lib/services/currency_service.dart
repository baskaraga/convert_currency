import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String baseUrl = 'https://api.exchangerate-api.com/v4/latest/';

  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$baseCurrency'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      // Fallback ke data dummy jika offline
      print('Error fetching data: $e');
      return {
        "base": "USD",
        "rates": {
          "USD": 1.0,
          "IDR": 14000.0,
          "EUR": 0.85,
          "GBP": 0.75,
        }
      };
    }
  }
}
