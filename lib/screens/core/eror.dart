import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ErorScreen extends StatefulWidget {
  const ErorScreen({super.key});
  @override
  State<ErorScreen> createState() => _ErorScreenState();
}

class _ErorScreenState extends State<ErorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("404 - Eror Not Found"),
            const Gap(15),
            IconButton(
              icon: const Icon(
                CupertinoIcons.chevron_back,
              ),
              onPressed: () => GoRouter.of(context).pop(),
            )
          ],
        ),
      )),
    );
  }
}
