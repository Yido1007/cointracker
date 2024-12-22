import 'package:flutter/material.dart';

class CurrencyNotifier extends ChangeNotifier {
  String _currency = 'USD'; // Varsayılan para birimi: Dolar

  String get currency => _currency;

  void toggleCurrency() {
    _currency = _currency == 'USD' ? 'TRY' : 'USD';
    notifyListeners();
  }
}
