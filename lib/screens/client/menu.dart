import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/theme.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tema Ayarları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButton<ThemeMode>(
              value: themeNotifier.themeMode,
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  themeNotifier.toggleTheme(newMode); 
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Sistem Teması'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Açık Tema'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Koyu Tema'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
