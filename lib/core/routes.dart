
import 'package:cointracker/screens/client/search.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/client/coinchart.dart';
import '../screens/core/loader.dart';
import '../screens/home.dart';
import '../screens/core/eror.dart';
import '../screens/static/boarding.dart';
import '../screens/static/home_frame.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// GoRouter configuration
final routes = GoRouter(
  navigatorKey: _rootNavigatorKey,
  errorBuilder: (context, state) => const ErorScreen(),
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => HomeScreen(
        state: state,
        child: child,
      ),
      routes: [
        GoRoute(
          parentNavigatorKey: _shellNavigatorKey,
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreenFrame()),
        ),
        GoRoute(
          parentNavigatorKey: _shellNavigatorKey,
          path: '/search',
          pageBuilder: (context, state) => const NoTransitionPage(child: SearchScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const LoaderScreen(),
    ),
    GoRoute(
      path: '/boarding',
      builder: (context, state) => const BoardingScreen(),
    ),
    // CoinChartPage için üst düzey rota
    GoRoute(
      path: '/coin_chart/:coinId',
      builder: (context, state) {
        // Dinamik rota parametresini alıyoruz
        final coinId = state.pathParameters['coinId'] ?? 'default_coin';
        return CoinChartPage(coinId: coinId);
      },
    ),
  ],
);
