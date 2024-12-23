import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/currency_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: CurrencyConverterScreen(),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  TextEditingController amountController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CurrencyProvider>(context, listen: false)
          .fetchExchangeRates('USD');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: provider.isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Enter Amount",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.teal.shade50,
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.attach_money, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      provider.updateBaseAmount(
                          double.tryParse(value) ?? 1.0);
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Converted Currencies",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: provider.selectedCurrencies.keys.map((key) {
                        return _buildCurrencyCard(context, provider, key);
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCurrencyCard(
      BuildContext context, CurrencyProvider provider, String inputKey) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            DropdownButton<String>(
              value: provider.selectedCurrencies[inputKey],
              items: provider.exchangeRates?['rates'].keys
                      .map<DropdownMenuItem<String>>((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList() ??
                  [],
              onChanged: (value) {
                if (value != null) {
                  provider.updateCurrency(inputKey, value);
                }
              },
              dropdownColor: Colors.teal.shade50,
              style: TextStyle(color: Colors.teal.shade700),
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  provider.convertedAmounts[inputKey]?.toStringAsFixed(2) ??
                      '0.00',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  inputKey,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
