import "dart:collection";
import "dart:convert";
import 'dart:io';
import "package:path/path.dart" as p;
import "package:flutter/material.dart";
import "package:mod_manager/util/config_file.dart";
import "package:url_launcher/url_launcher.dart";
import "package:http/http.dart" as http;

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
      debugShowCheckedModeBanner: false,
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
              Tab(
                icon: Icon(Icons.games),
                text: "Game",
              ),
              Tab(
                icon: Icon(Icons.add_to_photos),
                text: "Instances",
              ),
              Tab(icon: Icon(Icons.show_chart_rounded), text: "Leaderboards"),
              Tab(
                icon: Icon(Icons.settings),
                text: "Settings",
              ),
            ],
            onTap: (value) =>
                {setWindowTitle("ModManager - ${tabNames[value]}")},
          ),
          title: Text(winTitle),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: supportDialog,
              icon: const Icon(Icons.contact_support),
              tooltip: "Support",
            )
          ],
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
          tooltip: "Launch game",
          onPressed: () {
            if (SettingsTabState.gameType == "Steam") {
              var uri = Uri.parse("steam://rungameid/1329500");
              launchUrl(uri);
            }
            var stat = MyApp.cfg.getStatInt("times_launched");
            stat++;
            MyApp.cfg.setStat("times_launched", stat);
            setState(() {
              var _ = 1 * 1;
            });
          },
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }

  String support_subject = "";
  String support_user = "";
  String support_notes = "";

  void supportDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, subDialogSetState) {
            return AlertDialog(
              title: const Text("Support"),
              content: Column(children: [
                const Text("Please fill in the following:"),
                const Divider(),
                const Text("A brief description of the problem:"),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    support_subject = value;
                  },
                ),
                const Text(""),
                const Text("Your Discord username and tag: (example#1234)"),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    support_user = value;
                  },
                ),
                const Text(""),
                const Text("Any extra notes:"),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    support_notes = value;
                  },
                  minLines: 1,
                  maxLines: 3,
                ),
                const Text(""),
                const Text(
                    "Note: this will upload your BepInHecks log file for devs to see"),
              ]),
              actions: [
                TextButton(
                    onPressed: () {
                      sendSupport();
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: const Text("Submit")),
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          });
        });
  }

  Future<void> sendSupport() async {
    var url =
        Uri.parse("https://croiqlfjgofhokfrpagk.supabase.co/rest/v1/Support");

    Map<String, String> headers = HashMap();
    headers.putIfAbsent("Accept", () => "application/json");
    headers.putIfAbsent(
        "apikey",
        () =>
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyb2lxbGZqZ29maG9rZnJwYWdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjU3ODE3NDQsImV4cCI6MTk4MTM1Nzc0NH0.OBdI7jvIYdI1lwVqxJa41L4ASoQuCb6n3GKolwVYglA");
    headers.putIfAbsent("Content-Type", () => "application/json");

    var json = jsonEncode({
      "subject": support_subject,
      "discord_mention": support_user,
      "notes": support_notes,
      "logs": getLogFile()
    });
    try {
      http.Response response = await http.post(
        url,
        body: json,
        headers: headers,
      );
    } on Exception catch (e) {
      print("Error sending support: $e");
    }
  }

  String getLogFile() {
    var logFile =
        File(p.join(SettingsTabState.gamePath, "BepInEx", "LogOutput.log"));
    if (logFile.existsSync()) {
      return logFile.readAsStringSync();
    } else {
      return "no-log-sent";
    }
  }
}
