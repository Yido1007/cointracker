import 'package:flutter/material.dart';

import '../../model/coin.dart';
import '../client/coinchart.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coin Listesi'),
      ),
      body: FutureBuilder<List<Coin>>(
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
              return ListTile(
                leading: Image.network(coin.image, width: 40, height: 40),
                title: Text(coin.name),
                subtitle: Text('${coin.currentPrice} USD'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CoinChartPage(coinId: coin.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
