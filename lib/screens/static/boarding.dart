import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:preload_page_view/preload_page_view.dart';
import '../../core/storage.dart';
import '../../widget/boardingitem.dart';

class BoardingScreen extends StatefulWidget {
  const BoardingScreen({super.key});

  @override
  State<BoardingScreen> createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingScreen> {
  // Boarding Screen image, title and description
  final boardingData = [
    {
      "title": "Welcome to Crypto World!",
      "description":
          "Here is the easiest way to manage your cryptocurrency portfolio. Track your crypto assets with instant price updates, investment strategies and much more. Let's get started !",
    },
    {
      "title": "Notification.",
      "description":
          "Be aware of market fluctuations instantly. Be the first to be informed about price changes and important developments with special notifications. Customize the settings according to yourself.",
    },
    {
      "title": "Ready For Start ?",
      "description":
          "You're ready now! Track your portfolio, set your notifications and navigate the crypto world with confidence. When you need help, we are always here.",
    },
  ];

  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PreloadPageView.builder(
          itemCount: boardingData.length,
          preloadPagesCount: boardingData.length,
          onPageChanged: (value) {
            setState(() {
              page = value;
            });
          },
          itemBuilder: (context, index) => BoardingItem(
            // BoardingItem
            title: boardingData[index]["title"]!,
            description: boardingData[index]["description"]!,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              // 3 Dot
              height: 70,
              child: Align(
                alignment: Alignment.center,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: boardingData.length,
                  itemBuilder: (context, index) => Icon(
                    page == index ? Icons.circle_outlined : Icons.circle,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: OutlinedButton(
                onPressed: () async {
                  final storage = Storage();
                  await storage.firstLaunched();
                  GoRouter.of(context).replace("/home");
                },
                child: Text(page == boardingData.length - 1 ? "Bitir" : "Atla"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
