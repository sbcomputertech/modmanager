import "package:flutter/material.dart";
import "package:mod_manager/main.dart";
import "package:settings_ui/settings_ui.dart";
import "package:file_picker/file_picker.dart";

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});
  @override
  State<SettingsTab> createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab> {
  static String gameType =
      MyApp.cfg.getSetting("general", "game_type") as String;
  static String gamePath =
      MyApp.cfg.getSetting("general", "game_path") as String;
  static bool dev = MyApp.cfg.getSetting("general", "dev") as bool;
  static String instPath =
      MyApp.cfg.getSetting("general", "instance_root") as String;

  void changeGameType(String newVal) {
    setState(() {
      gameType = newVal;
    });
    MyApp.cfg.updateSettings("general", "game_type", newVal);
  }

  void changeGamePath() {
    FilePicker.platform
        .getDirectoryPath(dialogTitle: "Locate game path")
        .then((value) {
      setState(() {
        gamePath = value ?? "None";
      });
      MyApp.cfg.updateSettings("general", "game_path", gamePath);
    });
  }

  void changeDevMode(value) {
    setState(() {
      dev = value;
    });
    MyApp.cfg.updateSettings("general", "dev", value);
  }

  void changeInstPath() {
    FilePicker.platform
        .getDirectoryPath(dialogTitle: "Select isnstance root")
        .then((value) {
      setState(() {
        instPath = value ?? "None";
      });
      MyApp.cfg.updateSettings("general", "instance_root", instPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SettingsList(sections: [
        SettingsSection(
          title: const Text("General"),
          tiles: [
            SettingsTile(
              title: const Text("Game type"),
              value: Text(gameType),
              onPressed: (context) {
                if (gameType == "Steam") {
                  changeGameType("Epic");
                } else {
                  changeGameType("Steam");
                }
              },
            ),
            SettingsTile(
              title: const Text("Game path"),
              value: Text(gamePath),
              onPressed: (context) => changeGamePath(),
            ),
            SettingsTile(
              title: const Text("Instances root"),
              value: Text(instPath),
              onPressed: (context) => changeInstPath(),
            ),
            SettingsTile.switchTile(
                initialValue: dev,
                onToggle: (value) {
                  changeDevMode(value);
                },
                enabled: true,
                title: const Text("Developer mode (doesn't do anything yet)")),
          ],
        ),
      ]),
    );
  }
}
