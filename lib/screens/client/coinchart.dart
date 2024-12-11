// coinchart.dart
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
  List<String> timeLabels = [];
  double minY = 0;
  double maxY = 0;
  double interval = 0;
  String selectedRange = '1'; // Default to 1-day range

  Future<List<FlSpot>> fetchCoinPrices(String days) async {
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/${widget.coinId}/market_chart?vs_currency=usd&days=$days');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> prices = data['prices'];

      timeLabels = prices.map((entry) {
        final timestamp = entry[0];
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);

        if (selectedRange == '1') {
          return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
        } else {
          return '${dateTime.day}/${dateTime.month}';
        }
      }).toList();

      final List<FlSpot> spots = prices
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value[1]))
          .toList();

      minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

      const double padding = 0.3;
      final range = maxY - minY;
      minY -= range * padding;
      maxY += range * padding;

      // Dinamik interval hesaplama
      interval = calculateDynamicInterval(minY, maxY);

      return spots;
    } else {
      throw Exception('Grafik verileri alınamadı!');
    }
  }

  double calculateDynamicInterval(double min, double max) {
    final range = max - min;
    if (range < 1) {
      return 0.1; // Küçük fiyatlar için küçük aralık
    } else if (range < 10) {
      return 1; // 1-10 arasında fiyatlar için
    } else if (range < 100) {
      return 10; // 10-100 arasında fiyatlar için
    } else if (range < 1000) {
      return 50; // 100-1000 arasında fiyatlar için
    } else {
      return 500; // Büyük fiyatlar için daha büyük aralık
    }
  }

  @override
  void initState() {
    super.initState();
    futureSpots = fetchCoinPrices(selectedRange);
  }

  void updateChartRange(String range) {
    setState(() {
      selectedRange = range;
      futureSpots = fetchCoinPrices(range);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.coinId.toUpperCase()} Grafiği'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: FutureBuilder<List<FlSpot>>(
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
                            dotData: const FlDotData(show: false), // Noktaları gizle
                          ),
                        ],
                        minY: minY,
                        maxY: maxY,
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < timeLabels.length - 1) {
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
                                  selectedRange == '1'
                                      ? 'Saat: $time\nFiyat: \$${spot.y.toStringAsFixed(4)}'
                                      : 'Tarih: $time\nFiyat: \$${spot.y.toStringAsFixed(4)}',
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => updateChartRange('1'),
                  child: const Text('1 Günlük'),
                ),
                ElevatedButton(
                  onPressed: () => updateChartRange('7'),
                  child: const Text('1 Haftalık'),
                ),
                ElevatedButton(
                  onPressed: () => updateChartRange('90'),
                  child: const Text('3 Aylık'),
                ),
              ],
            ),
            // Diğer içerikler eklenebilir
          ],
        ),
      ),
    );
  }
}
