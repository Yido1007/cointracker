import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/coin.dart';

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
