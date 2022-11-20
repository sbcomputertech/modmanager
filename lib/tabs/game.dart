import "package:flutter/material.dart";
import "package:mod_manager/util/padded_divider.dart";
import "../main.dart";
import "mods.dart";
import "settings.dart";

class GameTab extends StatefulWidget {
  const GameTab({super.key});
  @override
  State<GameTab> createState() => GameTabState();
}

class GameTabState extends State<GameTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(" \n "),
        const Text(
          "Game info",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          "Install path: ${SettingsTabState.gamePath}",
          style: const TextStyle(fontSize: 15),
        ),
        Text(
          "Current instance: ${ModsTabState.selectedInstance}",
          style: const TextStyle(fontSize: 15),
        ),
        PaddedDivider(),
        const Text(
          "Stats",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          "Times launched: ${MyApp.cfg.getStatInt("times_launched")}",
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
