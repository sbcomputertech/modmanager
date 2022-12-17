import "dart:io";
import "package:path/path.dart" as p;
import "package:archive/archive_io.dart";

int main(List<String> args) {
  if (args.isEmpty) {
    print("Error: build platform not specified.");
    return 1;
  }

  var platforms = ["windows", "linux"];
  if (!platforms.contains(args[0])) {
    print("Error: unrecognized platform '${args[0]}'.");
    return 1;
  }

  print("Starting build for '${args[0]}'...");
  if (args[0] == "windows") {
    windows().then((_) {
      print("Done!");
      return 0;
    });
  } else {
    linux().then((_) {
      print("Done!");
      return 0;
    });
  }
  return 1;
}

Future<void> windows() async {
  await Process.run("flutter build windows", [],
      runInShell: true, workingDirectory: p.current);
  var outDir = "out-windows";
  var outDirObj = Directory(outDir);
  if (outDirObj.existsSync()) {
    outDirObj.deleteSync(recursive: true);
  }
  outDirObj.createSync();
  var flutterBuildDir =
      p.join(p.current, "build", "windows", "runner", "Release");

  print("Building installer");
  await Process.run(p.join("installer", "build-installer-windows"), [],
      runInShell: true, workingDirectory: "installer");
  var installer_exe = File(p.join("installer", "installer.exe"));

  print("Copying files...");
  await copyPath(flutterBuildDir, outDir);
  var baseJsonPath = p.join(p.current, "modman.base.json");
  File(baseJsonPath).copySync(p.join(outDir, "modman.json"));
  await installer_exe.copy(p.join(outDir, "installer.exe"));

  print("Creating ZIP...");
  var encoder = ZipFileEncoder();
  encoder.zipDirectory(outDirObj, filename: "modman-windows.zip");
}

Future<void> linux() async {
  await Process.run("flutter build linux", [],
      runInShell: true, workingDirectory: p.current);
  var outDir = "out-linux";
  var outDirObj = Directory(outDir);
  if (outDirObj.existsSync()) {
    outDirObj.deleteSync(recursive: true);
  }
  outDirObj.createSync();
  var flutterBuildDir =
      p.join(p.current, "build", "linux", "release", "bundle");

  print("Copying files...");
  await copyPath(flutterBuildDir, outDir);
  var baseJsonPath = p.join(p.current, "modman.base.json");
  File(baseJsonPath).copySync(p.join(outDir, "modman.json"));

  print("Creating ZIP...");
  var encoder = ZipFileEncoder();
  encoder.zipDirectory(Directory(outDir), filename: "modman-linux.zip");
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
