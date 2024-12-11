import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CoinChartPage extends StatefulWidget {
  final String coinId;

  const CoinChartPage({super.key, required this.coinId});

  @override
  _CoinChartPageState createState() => _CoinChartPageState();
}

class _CoinChartPageState extends State<CoinChartPage> {
  late Future<List<FlSpot>> futureSpots;
  List<String> timeLabels = []; // Saat etiketleri
  double minY = 0; // Y ekseninin minimum değeri
  double maxY = 0; // Y ekseninin maksimum değeri

  Future<List<FlSpot>> fetchCoinPrices() async {
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/${widget.coinId}/market_chart?vs_currency=usd&days=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> prices = data['prices'];

      // Saat bilgilerini ve fiyatları dönüştürüyoruz
      timeLabels = prices.map((entry) {
        final timestamp = entry[0]; // Zaman damgası (milisaniye)
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
        return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }).toList();

      final List<FlSpot> spots = prices
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value[1]))
          .toList();

      // Minimum ve maksimum fiyatları hesapla
      minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

      // Min/max değerlerini daha iyi görünürlük için genişlet
      const double padding = 0.1; // %10 ek genişlik
      final range = maxY - minY;
      minY -= range * padding;
      maxY += range * padding;

      return spots;
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
            return const Center(child: CircularProgressIndicator());
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
                    barWidth: 3,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                minY: minY, // Y ekseni için minimum değer
                maxY: maxY, // Y ekseni için maksimum değer
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < timeLabels.length) {
                          return Text(
                            timeLabels[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final time = index >= 0 && index < timeLabels.length
                            ? timeLabels[index]
                            : 'Bilinmiyor';
                        return LineTooltipItem(
                          'Saat: $time\nFiyat: \$${spot.y.toStringAsFixed(4)}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
