import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage.dart';

class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key});

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen> {
  late Future<void> _loadAppFuture;

  Future<void> loadApp() async {
    final storage = Storage();
    storage.clearStorage();
    try {
      final isFirstLaunch = await storage.isFirstLaunch();
      if (isFirstLaunch) {
        GoRouter.of(context).replace("/boarding");
      } else {
        GoRouter.of(context).replace("/home");
      }
    } catch (e, stackTrace) {
      debugPrint('Hata: $e\n$stackTrace');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAppFuture = loadApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadAppFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Bir hata oluştu: ${snapshot.error}'),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
