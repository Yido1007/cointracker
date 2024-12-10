import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CoinChartPage extends StatefulWidget {
  final String coinId;

  const CoinChartPage({super.key, required this.coinId});

  @override
  _CoinChartPageState createState() => _CoinChartPageState();
}

class _CoinChartPageState extends State<CoinChartPage> {
  late Future<List<FlSpot>> futureSpots;

  Future<List<FlSpot>> fetchCoinPrices() async {
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/${widget.coinId}/market_chart?vs_currency=usd&days=7');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> prices = data['prices'];
      return prices
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value[1]))
          .toList();
    } else {
      throw Exception('Grafik verileri alınamadı!');
    }
  }

  @override
  void initState() {
    super.initState();
    futureSpots = fetchCoinPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.coinId.toUpperCase()} Grafiği'),
      ),
      body: FutureBuilder<List<FlSpot>>(
        future: futureSpots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final spots = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
