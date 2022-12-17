import "dart:convert";
import "dart:io";
import "package:http/http.dart" as http;
import "package:path/path.dart" as p;

Future<bool> checkForUpdate() async {
  var currentVersion = getCurrentVersion();
  var latestVersion = await getLatestVersion();
  return currentVersion != latestVersion;
}

String getCurrentVersion() =>
    File(p.join(getInstallPath(), "version.txt")).readAsStringSync();

void setCurrentVersion(String newV) =>
    File(p.join(getInstallPath(), "version.txt")).writeAsStringSync(newV);

Future<void> update() async {
  await Process.run("./install", []);
}

String getInstallPath() {
  if (Platform.isWindows) {
    return p.join(Platform.environment["USERPROFILE"] ?? ".", "AppData",
        "Local", "cobweb", "modmanager");
  } else if (Platform.isLinux) {
    return p.join(Platform.environment["HOME"] ?? ".", ".cobweb", "modmanager");
  } else {
    throw Exception("Platform not supported");
  }
}

Future<String> getLatestVersion() async {
  var versionFileUrl = Uri.parse(
      "https://raw.githubusercontent.com/sbcomputertech/modmanager/main/version.json");
  var response = await http.get(versionFileUrl);
  var json = jsonDecode(response.body);
  return json["latest"] as String;
}
