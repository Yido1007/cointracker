import 'dart:convert';
import 'package:http/http.dart' as http;

class Coin {
  final String id;
  final String name;
  final String symbol;
  final double currentPrice;
  final String image;

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.image,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      currentPrice: json['current_price'].toDouble(),
      image: json['image'],
    );
  }
}

Future<List<Coin>> fetchCoins() async {
  final url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Coin.fromJson(json)).toList();
  } else {
    throw Exception('Coin verileri alınamadı!');
  }
}
