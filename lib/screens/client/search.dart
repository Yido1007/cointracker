import 'package:cointracker/screens/client/coinchart.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;

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

    final url = Uri.parse('https://api.coingecko.com/api/v3/search?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        searchResults = data['coins'];
        isLoading = false;
      });
    } else {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      throw Exception('Coin bilgisi alınamadı!');
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
              child: searchResults.isEmpty
                  ? const Center(child: Text('Sonuç bulunamadı'))
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
                            // Grafik sayfasına yönlendirme
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
      ),
    );
  }
}
