import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/coin.dart';
import '../../services/coin.dart';

class HomeScreenFrame extends StatefulWidget {
  const HomeScreenFrame({super.key});

  @override
  State<HomeScreenFrame> createState() => _HomeScreenFrameState();
}

class _HomeScreenFrameState extends State<HomeScreenFrame> {
  late Future<List<Coin>> futureCoins;
  String selectedCurrency = 'USD'; // Varsayılan para birimi

  @override
  void initState() {
    super.initState();
    futureCoins = fetchCoins();
  }

  Future<void> _refreshCoins() async {
    setState(() {
      futureCoins = fetchCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Listesi'),
        actions: [
          IconButton(
            onPressed: () {
              // Para birimini değiştir
              setState(() {
                selectedCurrency = selectedCurrency == 'USD' ? 'TRY' : 'USD';
              });
            },
            icon: Icon(
              selectedCurrency == 'USD' ? Icons.attach_money : Icons.currency_lira,
            ),
            tooltip: 'Para Birimi: $selectedCurrency',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCoins,
        child: FutureBuilder<List<Coin>>(
          future: futureCoins,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Hata: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Coin bulunamadı.'));
            }

            final coins = snapshot.data!;
            return ListView.builder(
              itemCount: coins.length,
              itemBuilder: (context, index) {
                final coin = coins[index];
                final priceChangeColor = coin.priceChangePercentage24h >= 0
                    ? Colors.green
                    : Theme.of(context).colorScheme.error;

                // Fiyat dönüşümü
                final currentPrice = selectedCurrency == 'USD'
                    ? '\$${coin.currentPrice.toStringAsFixed(2)}'
                    : '${(coin.currentPrice * 27).toStringAsFixed(2)} ₺';

                return ListTile(
                  leading: Image.network(coin.image, width: 40, height: 40),
                  title: Text(coin.name),
                  subtitle: Text(currentPrice), // Dinamik fiyat
                  trailing: Text(
                    '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                    style: TextStyle(color: priceChangeColor),
                  ),
                  onTap: () {
                    context.push('/coin_chart/${coin.id}');
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
