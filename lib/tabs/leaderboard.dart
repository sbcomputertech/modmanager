import "dart:async";
import "dart:collection";
import "dart:convert";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});
  @override
  State<LeaderboardTab> createState() => LeaderboardTabState();
}

class LeaderboardTabState extends State<LeaderboardTab> {
  List<Widget> entries = List.empty(growable: true);
  Timer? timer;
  String selected = "-= Select a mod =-";
  int stateUpdate = 0;
  List<String> guids = List.empty(growable: true);

  void update(List<dynamic> data) {
    entries.clear();
    entries.add(makeDropdown());

    guids.clear();
    guids.add("~~Select a mod~~");
    for (var element in data) {
      var guid = element["mod_guid"];
      if (!guids.contains(guid)) guids.add(guid);
    }

    for (var element in data) {
      if (element["mod_guid"] != selected) continue;
      entries.add(Text(
          "Player: ${element["player_name"]}, Score: ${element["score"]}"));
    }
    setState(() {
      stateUpdate++;
    });
  }

  Widget makeDropdown() {
    if (entries.isNotEmpty) {
      return DropdownButton<String>(
        focusColor: Colors.white,
        value: selected,
        //elevation: 5,
        style: const TextStyle(color: Colors.white),
        iconEnabledColor: Colors.black,
        items: guids.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        hint: const Text(
          "-= Select a mod =-",
          style: TextStyle(color: Colors.black),
        ),
        onChanged: (String? value) {
          setState(() {
            selected = value ?? "none";
          });
        },
      );
    } else {
      return const Text("No leaderboard scores found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(children: entries),
    );
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) => getLb().then((value) => {
              if (value != null) {update(value)}
            }));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<List<dynamic>?> getLb() async {
    var url = Uri.parse(
        "https://croiqlfjgofhokfrpagk.supabase.co/rest/v1/Leaderboards?select=*");

    Map<String, String> headers = HashMap();
    headers.putIfAbsent("Accept", () => "application/json");
    headers.putIfAbsent(
        "apikey",
        () =>
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyb2lxbGZqZ29maG9rZnJwYWdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjU3ODE3NDQsImV4cCI6MTk4MTM1Nzc0NH0.OBdI7jvIYdI1lwVqxJa41L4ASoQuCb6n3GKolwVYglA");

    try {
      http.Response response = await http.get(
        url,
        headers: headers,
      );
      return jsonDecode(response.body);
    } on Exception catch (e) {
      print("Error getting leaderboard: $e");
      return null;
    }
  }
}
