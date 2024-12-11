import 'dart:io';

import 'package:bps_bintan/http_overrides.dart';
import 'package:bps_bintan/list_news_page.dart';
import 'package:bps_bintan/list_publication_page.dart';
import 'package:bps_bintan/providers/setting_provider.dart';
import 'package:bps_bintan/publication_delegate.dart';
import 'package:bps_bintan/settings_page.dart';
import 'package:bps_bintan/news_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides(); // Pasang HttpOverrides

  runApp(ChangeNotifierProvider(
    create: (context) => SettingsProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, value, child) => MaterialApp(
        title: 'Flutter Demo',
        theme: value.isDarkMode
            ? ThemeData.dark(useMaterial3: false)
            : ThemeData.light(useMaterial3: false),
        home: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPage = 0;
  Widget body() {
    switch (currentPage) {
      case 0:
        return const ListNewsPage();
      case 1:
        return const ListPublicationPage();
      case 2:
        return const SettingsPage();
      default:
        return const ListNewsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: value.language == 'Indonesian'
              ? Text(currentPage == 0
                  ? "Berita"
                  : currentPage == 1
                      ? "Publikasi"
                      : 'Pengaturan')
              : Text(currentPage == 0
                  ? "News"
                  : currentPage == 1
                      ? "Publication"
                      : 'Setting'),
          actions: [
            currentPage != 2
                ? IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: currentPage == 0
                            ? NewsSearchDelegate1(context)
                            : PublicationSearchDelegate1(context),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ],
        ),
        drawer: buildDrawer(context),
        // body: Stack(
        //   children: [
        //     const Align(
        //       alignment: Alignment.center,
        //       child: RotatedBox(
        //         quarterTurns: 1,
        //         child: Text(
        //           'Created by Syarif Hidayatullah',
        //           style: TextStyle(
        //             fontSize: 32,
        //           ),
        //         ),
        //       ),
        //     ),
        //     body(),
        //   ],
        // ),
        body: body(),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(),
      child: Consumer<SettingsProvider>(
        builder: (context, value, child) => ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 100,
                  ),
                  const Text(
                    'BPS Bintan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.keyboard_arrow_right_rounded),
              selected: currentPage == 0 ? true : false,
              title: Text(value.language == 'Indonesian' ? 'Berita' : 'News'),
              onTap: () {
                setState(() {
                  currentPage = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                  value.language == 'Indonesian' ? 'Publikasi' : 'Publication'),
              leading: const Icon(Icons.keyboard_arrow_right_rounded),
              selected: currentPage == 1 ? true : false,
              onTap: () {
                setState(() {
                  currentPage = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                  value.language == 'Indonesian' ? 'Pengaturan' : 'Settings'),
              leading: const Icon(Icons.keyboard_arrow_right_rounded),
              selected: currentPage == 2 ? true : false,
              onTap: () {
                setState(() {
                  currentPage = 2;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
