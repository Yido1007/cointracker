import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../bloc/client_cubit.dart';
import '../../core/localizations.dart';
import '../../provider/theme.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late ClientCubit clientCubit;

  @override
  void initState() {
    super.initState();
    clientCubit = context.read<ClientCubit>();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return BlocBuilder<ClientCubit, ClientState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).getTranslate("home")),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).push("/lang");
                  },
                  child: const Text("Lang")),
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
    });
  }
}
