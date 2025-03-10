import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class BottomMenu extends StatelessWidget {
  final String currentPath;

  const BottomMenu({
    super.key,
    required this.currentPath,
  });

  int _getSelectedIndex() {
    switch (currentPath) {
      case "/home":
        return 0;
      case "/search":
        return 1;
      case "/menu":
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getSelectedIndex(),
      onTap: (value) {
        switch (value) {
          case 0:
            GoRouter.of(context).go("/home");
            break;
          case 1:
            GoRouter.of(context).go("/search");
            break;
        }
      },
      // Home Screen Navigation
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.currency_bitcoin_sharp),
          label: ("Ana Sayfa"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: ("Arama"),
        ),
      ],
    );
  }
}
