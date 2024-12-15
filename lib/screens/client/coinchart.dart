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
  late Future<Map<String, dynamic>> coinStats;
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

      interval = calculateDynamicInterval(minY, maxY);

      return spots;
    } else {
      throw Exception('Grafik verileri alınamadı!');
    }
  }

  Future<Map<String, dynamic>> fetchCoinStats() async {
    final url = Uri.parse('https://api.coingecko.com/api/v3/coins/${widget.coinId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'popularity': data['market_cap_rank'],
        'marketCap': data['market_data']['market_cap']['usd'],
        'high24h': data['market_data']['high_24h']['usd'],
        'low24h': data['market_data']['low_24h']['usd'],
        'allTimeHigh': data['market_data']['ath']['usd'],
      };
    } else {
      throw Exception('Coin istatistikleri alınamadı!');
    }
  }

  double calculateDynamicInterval(double min, double max) {
    final range = max - min;
    if (range < 1) {
      return 0.1;
    } else if (range < 10) {
      return 1;
    } else if (range < 100) {
      return 10;
    } else if (range < 1000) {
      return 50;
    } else {
      return 500;
    }
  }

  String formatMarketCap(num marketCap) {
    // num kullanıyoruz, hem int hem double kabul eder.
    final double marketCapDouble = marketCap.toDouble(); // marketCap'i double'a dönüştür
    if (marketCapDouble >= 1e12) {
      return '${(marketCapDouble / 1e12).toStringAsFixed(2)} trilyon dolar';
    } else if (marketCapDouble >= 1e9) {
      return '${(marketCapDouble / 1e9).toStringAsFixed(2)} milyar dolar';
    } else if (marketCapDouble >= 1e6) {
      return '${(marketCapDouble / 1e6).toStringAsFixed(2)} milyon dolar';
    } else {
      return '\$${marketCapDouble.toStringAsFixed(2)}';
    }
  }

  @override
  void initState() {
    super.initState();
    futureSpots = fetchCoinPrices(selectedRange);
    coinStats = fetchCoinStats();
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
                            dotData: const FlDotData(show: false),
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
            FutureBuilder<Map<String, dynamic>>(
              future: coinStats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }
                final stats = snapshot.data!;
                final marketCap = stats['marketCap'];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Popülerlik Sırası: #${stats['popularity']}'),
                      Text('Piyasa Değeri: ${formatMarketCap(marketCap)}'),
                      Text('24 Saat Yüksek: \$${stats['high24h']}'),
                      Text('24 Saat Düşük: \$${stats['low24h']}'),
                      Text('Tüm Zamanların En Yükseği: \$${stats['allTimeHigh']}'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
