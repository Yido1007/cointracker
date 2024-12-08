import 'package:go_router/go_router.dart';
import '../screens/core/eror.dart';
import '../screens/core/loader.dart';
import '../screens/home.dart';
import '../screens/static/boarding.dart';

// GoRouter configuration
final routes = GoRouter(
  errorBuilder: (context, state) => const ErorScreen(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoaderScreen(),
    ),
    GoRoute(
      path: '/boarding',
      builder: (context, state) => const BoardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
