import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/currency_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  final CurrencyService _service = CurrencyService();
  Map<String, dynamic>? exchangeRates;
  bool isLoading = false;

  String baseCurrency = 'USD';
  double baseAmount = 1.0;

  Map<String, String> selectedCurrencies = {
    'input1': 'USD',
    'input2': 'IDR',
    'input3': 'EUR',
  };

  Map<String, double> convertedAmounts = {
    'input1': 1.0,
    'input2': 0.0,
    'input3': 0.0,
  };

  Future<void> fetchExchangeRates(String newBaseCurrency) async {
    isLoading = true;
    notifyListeners();

    try {
      // Coba ambil data dari API
      final rates = await _service.getExchangeRates(newBaseCurrency);
      exchangeRates = rates;
      baseCurrency = newBaseCurrency;
      _recalculateAmounts();
      await _saveToCache(rates); // Simpan data ke cache
    } catch (e) {
      print('Error fetching data: $e');
      exchangeRates = await _loadFromCache(); // Coba ambil dari cache
      if (exchangeRates == null) {
        print('No data available offline');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Simpan data ke SharedPreferences
  Future<void> _saveToCache(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('exchangeRates', jsonEncode(data));
  }

  // Ambil data dari SharedPreferences
  Future<Map<String, dynamic>?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('exchangeRates');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  void updateBaseAmount(double amount) {
    baseAmount = amount;
    _recalculateAmounts();
  }

  void updateCurrency(String inputKey, String newCurrency) {
    selectedCurrencies[inputKey] = newCurrency;
    if (inputKey == 'input1') {
      fetchExchangeRates(newCurrency);
    } else {
      _recalculateAmounts();
    }
  }

  void _recalculateAmounts() {
    if (exchangeRates == null) return;

    convertedAmounts['input1'] = baseAmount;
    selectedCurrencies.forEach((key, currency) {
      if (key != 'input1' && exchangeRates!['rates'][currency] != null) {
        convertedAmounts[key] = baseAmount *
            (exchangeRates!['rates'][currency] /
                exchangeRates!['rates'][selectedCurrencies['input1']!]);
      }
    });
    notifyListeners();
  }
}
