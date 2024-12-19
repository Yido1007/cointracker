import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // GoRouter'ı ekleyin
import '../../model/coin.dart';
import '../../services/coin.dart';

class HomeScreenFrame extends StatefulWidget {
  const HomeScreenFrame({super.key});

  @override
  State<HomeScreenFrame> createState() => _HomeScreenFrameState();
}

class _HomeScreenFrameState extends State<HomeScreenFrame> {
  late Future<List<Coin>> futureCoins;

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
                final priceChangeColor =
                    coin.priceChangePercentage24h >= 0 ? Colors.green : Colors.red;

                return ListTile(
                  leading: Image.network(coin.image, width: 40, height: 40),
                  title: Text(coin.name),
                  subtitle: Text('${coin.currentPrice} USD'),
                  trailing: Text(
                    '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                    style: TextStyle(color: priceChangeColor),
                  ),
                  onTap: () {
                    // GoRouter ile yönlendirme
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
