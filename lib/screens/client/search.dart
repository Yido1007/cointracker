import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'coinchart.dart'; // Grafik sayfasını içe aktar

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  List<Map<String, dynamic>> searchHistory = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory(); // Uygulama açıldığında geçmişi yükle
  }

  // Coinleri API'den ara
  Future<void> searchCoins(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('https://api.coingecko.com/api/v3/search?query=$query');
      final response = await http.get(url);

      print('HTTP Durum Kodu: ${response.statusCode}');
      print('API Yanıtı: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['coins'] != null) {
          setState(() {
            searchResults = data['coins'];
            isLoading = false;
          });
        } else {
          throw Exception('API yanıtında beklenen veri bulunamadı!');
        }
      } else {
        throw Exception('HTTP isteği başarısız oldu. Durum Kodu: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      throw Exception('Coin bilgisi alınamadı!');
    }
  }

  // Yerel dosyadan geçmişi yükle
  Future<void> _loadSearchHistory() async {
    try {
      final file = await _getHistoryFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        setState(() {
          searchHistory = List<Map<String, dynamic>>.from(json.decode(contents));
        });
      }
    } catch (e) {
      print('Geçmiş yüklenirken hata: $e');
    }
  }

  Future<void> _saveSearchHistory() async {
    try {
      final file = await _getHistoryFile();
      final contents = json.encode(searchHistory);
      await file.writeAsString(contents);
    } catch (e) {
      print('Geçmiş kaydedilirken hata: $e');
    }
  }

  Future<File> _getHistoryFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/search_history.json');
  }

  void addToHistory(Map<String, dynamic> coin) {
    setState(() {
      if (!searchHistory.any((item) => item['id'] == coin['id'])) {
        searchHistory.add(coin);
      }
    });
    _saveSearchHistory();
  }

  void clearHistory() async {
    setState(() {
      searchHistory.clear();
    });
    final file = await _getHistoryFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Arama'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                searchCoins(value);
              },
              decoration: InputDecoration(
                labelText: 'Coin Ara',
                border: const OutlineInputBorder(),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchCoins('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading) const CircularProgressIndicator(),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: searchResults.isEmpty
                        ? const Center(child: Text(''))
                        : ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final coin = searchResults[index];
                              return ListTile(
                                leading: Image.network(
                                  coin['thumb'],
                                  width: 40,
                                  height: 40,
                                ),
                                title: Text(coin['name']),
                                subtitle: Text(coin['symbol'].toUpperCase()),
                                onTap: () {
                                  addToHistory(coin);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CoinChartPage(coinId: coin['id']),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  if (searchHistory.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Geçmiş',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: clearHistory,
                              child: Text(
                                'Temizle',
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            itemCount: searchHistory.length,
                            itemBuilder: (context, index) {
                              final coin = searchHistory[index];
                              return ListTile(
                                leading: Image.network(
                                  coin['thumb'],
                                  width: 40,
                                  height: 40,
                                ),
                                title: Text(coin['name']),
                                subtitle: Text(coin['symbol'].toUpperCase()),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CoinChartPage(coinId: coin['id']),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
