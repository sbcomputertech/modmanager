import 'package:flutter/material.dart';
import 'package:mod_manager/main.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:file_picker/file_picker.dart';

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
  static bool doorstopLog = MyApp.cfg.getSetting("doorstop", "logging") as bool;
  static bool doorstopDebug = MyApp.cfg.getSetting("doorstop", "debug") as bool;
  static bool bepinhecksConsole =
      MyApp.cfg.getSetting("bepinhecks", "console") as bool;

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

  void changeDoorstopLogging(value) {
    setState(() {
      doorstopLog = value;
    });
    MyApp.cfg.updateSettings("doorstop", "logging", value);
  }

  void changeDoorstopDebugging(value) {
    setState(() {
      doorstopDebug = value;
    });
    MyApp.cfg.updateSettings("doorstop", "debug", value);
  }

  void changeBepinhecksConsole(value) {
    setState(() {
      bepinhecksConsole = value;
    });
    MyApp.cfg.updateSettings("bepinhecks", "console", value);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SettingsList(sections: [
        SettingsSection(
          title: const Text("Game"),
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
          ],
        ),
        SettingsSection(
          title: const Text("Doorstop"),
          tiles: [
            SettingsTile.switchTile(
                initialValue: doorstopLog,
                onToggle: (value) {
                  changeDoorstopLogging(value);
                },
                enabled: true,
                title: const Text("Doorstop logging")),
            SettingsTile.switchTile(
                initialValue: doorstopDebug,
                onToggle: (value) {
                  changeDoorstopDebugging(value);
                },
                enabled: true,
                title: const Text("Doorstop debugging")),
          ],
        ),
        SettingsSection(title: const Text("BepInHecks"), tiles: [
          SettingsTile.switchTile(
              initialValue: bepinhecksConsole,
              onToggle: (value) {
                changeBepinhecksConsole(value);
              },
              enabled: true,
              title: const Text("BepInHecks console")),
        ]),
      ]),
    );
  }
}
