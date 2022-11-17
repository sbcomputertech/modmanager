import 'package:flutter/material.dart';
import 'package:mod_manager/util/config_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'tabs/game.dart';
import 'tabs/mods.dart';
import 'tabs/leaderboard.dart';
import 'tabs/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ModManCfg cfg = ModManCfg.load();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ModManager',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.games)),
              Tab(icon: Icon(Icons.add_to_photos)),
              Tab(icon: Icon(Icons.show_chart_rounded)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
          title: const Text("Mod Manager"),
        ),
        body: const TabBarView(
          children: [
            GameTab(),
            ModsTab(),
            LeaderboardTab(),
            SettingsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (SettingsTabState.gameType == "Steam") {
              var uri = Uri.parse("steam://rungameid/1329500");
              launchUrl(uri);
            }
          },
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}
