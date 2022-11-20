import "package:flutter/material.dart";
import "package:mod_manager/util/config_file.dart";
import "package:url_launcher/url_launcher.dart";

import "tabs/game.dart";
import "tabs/mods.dart";
import "tabs/leaderboard.dart";
import "tabs/settings.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ModManCfg cfg = ModManCfg.load();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ModManager",
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
  void setWindowTitle(String newTitle) {
    setState(() {
      winTitle = newTitle;
    });
  }

  final tabNames = <String>["Game", "Instances", "Leaderboard", "Settings"];

  String winTitle = "ModManager";
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.games)),
              Tab(icon: Icon(Icons.add_to_photos)),
              Tab(icon: Icon(Icons.show_chart_rounded)),
              Tab(icon: Icon(Icons.settings)),
            ],
            onTap: (value) =>
                {setWindowTitle("ModManager - ${tabNames[value]}")},
          ),
          title: Text(winTitle),
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
            var stat = MyApp.cfg.getStatInt("times_launched");
            stat++;
            MyApp.cfg.setStat("times_launched", stat);
            setState(() {
              var x = 1 * 1;
            });
          },
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}
