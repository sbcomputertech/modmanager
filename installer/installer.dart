import "dart:convert";
import "dart:io";
import "package:archive/archive.dart";
import "package:http/http.dart" as http;
import "package:path/path.dart" as p;

void main(List<String> args) {
  if (isInstalled()) {
    uninstall();
  }
  install();
}

void dumpEnv() {
  for (var key in Platform.environment.keys) {
    var val = Platform.environment[key];
    print("ENV: $key = $val");
  }
}

void uninstall() {
  var dir = Directory(getInstallPath());
  dir.deleteSync();
  print("Uninstalled");
}

bool isInstalled() {
  var dir = Directory(getInstallPath());
  return dir.existsSync();
}

Future<void> install() async {
  var version = await getLatestVersion();
  print("Latest version: $version");
  downloadZip(version, "windows");
  writeVersionFile(version);
}

Future<void> writeVersionFile(String version) async {
  var versionFile = File(p.join(getInstallPath(), "version.txt"));
  if (versionFile.existsSync()) {
    versionFile.deleteSync();
  }
  versionFile.createSync();
  versionFile.writeAsStringSync(version);
}

Future<void> downloadZip(String version, String platform) async {
  var objectUrl = Uri.parse(
      "https://croiqlfjgofhokfrpagk.supabase.co/storage/v1/object/public/modmanager-versions/$version/modman-$platform.zip");
  var resp = await http.get(objectUrl);
  final archive = ZipDecoder().decodeBytes(resp.bodyBytes);
  String zipOutDir = getInstallPath();
  print("Install dir: $zipOutDir");

  for (final file in archive) {
    final filename = file.name;
    if (file.isFile) {
      final data = file.content as List<int>;
      File("$zipOutDir/$filename")
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory("$zipOutDir/$filename").create(recursive: true);
    }
  }
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
