import "dart:io";
import "package:mod_manager/tabs/settings.dart";
import "package:path/path.dart" as p;

void switchVanilla() {
  uninstallBepinex();
}

Future<void> uninstallBepinex() async {
  var installLoc = SettingsTabState.gamePath;
  if (Platform.isWindows) {
    await Process.run("$installLoc\\Uninstall_Bepinhecks.bat", [],
        workingDirectory: installLoc);
  } else {
    await Process.run("sh", ["$installLoc/UninstallBepinhecks.sh"],
        workingDirectory: installLoc);
  }
}

void switchInstance(id) {
  fileChangeover(p.join(SettingsTabState.instPath, id));
}

Future<void> copyPath(String from, String to) async {
  await Directory(to).create(recursive: true);
  await for (final file in Directory(from).list(recursive: true)) {
    final copyTo = p.join(to, p.relative(file.path, from: from));
    if (file is Directory) {
      await Directory(copyTo).create(recursive: true);
    } else if (file is File) {
      await File(file.path).copy(copyTo);
    } else if (file is Link) {
      await Link(copyTo).create(await file.target(), recursive: true);
    }
  }
}

Future<bool> isBepinexPresent() {
  var installLoc = SettingsTabState.gamePath;
  String bepinexDir;
  if (Platform.isWindows) {
    bepinexDir = "$installLoc\\BepInEx";
  } else {
    bepinexDir = "$installLoc/BepInEx";
  }

  return Directory(bepinexDir).exists();
}

Future<void> fileChangeover(String source) async {
  if (await isBepinexPresent()) {
    await uninstallBepinex();
  }
  await copyPath(source, SettingsTabState.gamePath);
}

void deleteInstanceFiles(String id) {
  var path = p.join(SettingsTabState.instPath, id);
  var dir = Directory(path);
  dir.deleteSync(recursive: true);
}
