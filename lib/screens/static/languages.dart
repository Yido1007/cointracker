import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../bloc/client_cubit.dart';
import '../../core/localizations.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late ClientCubit clientCubit;
  @override
  void initState() {
    super.initState();
    clientCubit = context.read<ClientCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientCubit, ClientState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          // language screen title
          title: Text(
            AppLocalizations.of(context).getTranslate("language"),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Gap(25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // to use Tr
                  InkWell(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/icons/turkey.png",
                          width: 80,
                        ),
                        const Text(
                          "Türkçe",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        )
                      ],
                    ),
                    onTap: () {
                      clientCubit.state.language == "tr"
                          ? null
                          : (
                              {
                                clientCubit.changeLanguage(language: "tr"),
                              },
                            );
                    },
                  ),
                  // to use En
                  InkWell(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/icons/england.png",
                          width: 80,
                        ),
                        const Text(
                          "English",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        )
                      ],
                    ),
                    onTap: () {
                      clientCubit.state.language == "en"
                          ? null
                          : (
                              {
                                clientCubit.changeLanguage(language: "en"),
                              },
                            );
                    },
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
