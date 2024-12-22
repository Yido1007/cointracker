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
  String selectedRange = '1';

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
        'popularity': data['market_cap_rank'] ?? 0, // Varsayılan değer
        'marketCap': (data['market_data']['market_cap']['usd'] ?? 0).toDouble(),
        'high24h': (data['market_data']['high_24h']['usd'] ?? 0).toDouble(),
        'low24h': (data['market_data']['low_24h']['usd'] ?? 0).toDouble(),
        'allTimeHigh': (data['market_data']['ath']['usd'] ?? 0).toDouble(),
        'volume24h': (data['market_data']['total_volume']['usd'] ?? 0).toDouble(),
        'volumeChange24h': (data['market_data']['price_change_percentage_24h'] ?? 0).toDouble(),
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

  String formatVolume(double volume) {
    if (volume >= 1e12) {
      return '${(volume / 1e12).toStringAsFixed(2)} trilyon dolar';
    } else if (volume >= 1e9) {
      return '${(volume / 1e9).toStringAsFixed(2)} milyar dolar';
    } else if (volume >= 1e6) {
      return '${(volume / 1e6).toStringAsFixed(2)} milyon dolar';
    } else {
      return '\$${volume.toStringAsFixed(2)}';
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
                            color: Theme.of(context).colorScheme.primary,
                            shadow: const Shadow(color: Colors.black38),
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
                            getTooltipColor: (touchedSpot) =>
                                Theme.of(context).colorScheme.secondary,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final index = spot.x.toInt();
                                final time = index >= 0 && index < timeLabels.length
                                    ? timeLabels[index]
                                    : 'Bilinmiyor';
                                return LineTooltipItem(
                                  selectedRange == '1'
                                      ? 'Saat: $time\nFiyat: \$${spot.y.toStringAsFixed(2)}'
                                      : 'Tarih: $time\nFiyat: \$${spot.y.toStringAsFixed(4)}',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipRoundedRadius: 8,
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
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
                  padding: const EdgeInsets.all(20.0),
                  child: GridView(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 25, // Dikey boşluk artırıldı
                      crossAxisSpacing: 15, // Yatay boşluk da istenirse ayarlanabilir
                      childAspectRatio: 5,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Text(
                        'Popülerlik Sırası:\n#${stats['popularity']}',
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        'Piyasa Değeri:\n${formatMarketCap(marketCap)}',
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        '24 Küresel Hacim:\n${formatVolume(stats['volume24h'])}',
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        '24S Hacim Değişimi:\n${stats['volumeChange24h'].toStringAsFixed(2)}%',
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        '24S En Yüksek:\n\$${stats['high24h']}',
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        '24S En Düşük:\n\$${stats['low24h']}',
                        textAlign: TextAlign.start,
                      ),
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
