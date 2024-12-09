import 'package:flutter/cupertino.dart';
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
      case "/news":
        return 1;
      case "/exchange":
        return 2;
      case "/settings":
        return 3;
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
            GoRouter.of(context).go("/news");
            break;
          case 2:
            GoRouter.of(context).go("/exchange");
            break;
          case 3:
            GoRouter.of(context).go("/settings");
            break;
        }
      },
      // Home Screen Navigation
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          label: ("home"),
        ),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.news),
          label: ("news"),
        ),
        // Coins Screen Navigation
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.money_dollar),
          label: ("exchange"),
        ),
        // Settings Screen Navigation
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: ("settings"),
        ),
      ],
    );
  }
}
