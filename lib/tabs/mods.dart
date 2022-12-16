import "dart:collection";
import "dart:convert";
import "dart:io";
import 'dart:ui';
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:mod_manager/main.dart";
import "package:mod_manager/tabs/settings.dart";
import "package:mod_manager/util/bepinhecks_install_helper.dart";
import "package:mod_manager/util/instance_file_manager.dart";
import "package:mod_manager/util/padded_divider.dart";
import "package:http/http.dart" as http;
import "package:path/path.dart" as p;

class ModsTab extends StatefulWidget {
  const ModsTab({super.key});
  @override
  State<ModsTab> createState() => ModsTabState();
}

class ModsTabState extends State<ModsTab> {
  static String selectedInstance = "";

  static void handleLaunchClick(instId) {
    switchInstance(instId);
    selectedInstance = instId;
  }

  List<Widget> genModWidgets(instId, jsonInp, dialogSetState) {
    var i = 0;
    List<Widget> out = List.empty(growable: true);
    for (var mod in jsonInp) {
      i++;
      out.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("$i: ${mod["name"]} v${mod["version"]}"),
          IconButton(
              onPressed: () {
                removeMod(instId, mod["id"]);
                dialogSetState(() {
                  var _ = 1 * 1;
                });
              },
              icon: const Icon(Icons.delete))
        ],
      ));
    }
    return out;
  }

  void removeMod(instId, modId) {
    var curr = MyApp.cfg.getInstanceId(instId);
    var modToRemove = getMod(curr["mods"], modId);
    (curr["mods"] as List<dynamic>).remove(modToRemove);
    MyApp.cfg.editInstance(instId, curr);
    removeModFromInstance(modId as String, instId);
  }

  dynamic getMod(mdodList, id) {
    for (var mod in mdodList) {
      if (mod["id"] == id) {
        return mod;
      }
    }
  }

  Future<FilePickerResult?> handleLocateModDLL(id) async {
    var preCwd = Directory.current;
    var f = await FilePicker.platform.pickFiles(
        dialogTitle: "Locate mod",
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: List.filled(1, "dll"));
    Directory.current = preCwd;
    return f;
  }

  void handleAddModFromDLL(FilePickerResult? res, String instId, String dllName,
      String dllId, String dllVersion) {
    if (res == null) return;
    if (res.files[0].path == null) return;
    addModToInstance(res.files[0].path ?? "uh this is an error", instId, dllId);
    MyApp.cfg.addMod(dllName, dllId, dllVersion, instId);
    Navigator.of(context, rootNavigator: true).pop();
  }

  void addMod(dialogSetState, instId, instName) {
    FilePickerResult? res;
    var dllName = "";
    var dllId = "";
    var dllVersion = "";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, subDialogSetState) {
            return AlertDialog(
              title: Text("Add mod to $instName"),
              content: Column(
                children: [
                  const Text("Get from ModWeaver"),
                  const Text(" "),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      enabled: false,
                      hintText: "Mod GUID",
                    ),
                    onChanged: (value) {},
                  ),
                  const Text(" "),
                  TextButton(onPressed: null, child: const Text("Install")),
                  const Divider(),
                  const Text("Add from a DLL file"),
                  const Text(" "),
                  TextButton(
                      onPressed: () {
                        handleLocateModDLL(instId).then((value) => res = value);
                      },
                      child: const Text("Locate...")),
                  const Text(" "),
                  TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Mod name",
                      ),
                      onChanged: (value) {
                        dllName = value;
                      }),
                  TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Mod ID",
                      ),
                      onChanged: (value) {
                        dllId = value;
                      }),
                  TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Mod version",
                      ),
                      onChanged: (value) {
                        dllVersion = value;
                      }),
                  const Text(" "),
                  TextButton(
                      onPressed: () {
                        handleAddModFromDLL(
                            res, instId, dllName, dllId, dllVersion);
                        dialogSetState(() {
                          var _ = 1 * 1;
                        });
                      },
                      child: const Text("Install")),
                ],
              ),
              actions: [
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

  void handleModsClick(instId) {
    var instances = MyApp.cfg.getInstances();
    dynamic selected;
    for (var ins in instances) {
      if (ins["id"] == instId) {
        selected = ins;
        break;
      }
    }
    var mods = selected["mods"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, dialogSetState) {
          return AlertDialog(
            title: Text('Mods installed to ${selected["name"]}'),
            content:
                Column(children: genModWidgets(instId, mods, dialogSetState)),
            actions: [
              TextButton(
                  onPressed: () {
                    addMod(dialogSetState, instId, selected["name"]);
                  },
                  child: const Text("Add...")),
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        });
      },
    );
  }

  void handleDeleteClick(id) {
    MyApp.cfg.deleteInstance(id);
    deleteInstanceFiles(id);
    setState(() {
      var _ = 1 * 1;
    });
  }

  void handleAddClick() {
    var instName = "";
    var instId = "";
    var bepinVersion = "latest";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, subDialogSetState) {
            return AlertDialog(
              title: const Text("Add an instance"),
              content: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Instance name",
                    ),
                    onChanged: (value) => instName = value,
                  ),
                  const Divider(),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          "Instance ID (letters, numbers, underscores only)",
                    ),
                    onChanged: (value) => instId = value,
                  ),
                  const Divider(),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "BepInHecks version (default latest)",
                    ),
                    onChanged: (value) => bepinVersion = value,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    createInstance(instName, instId, bepinVersion);
                  },
                  child: const Text("Done"),
                ),
              ],
            );
          });
        });
  }

  Future<void> createInstance(String name, String id, String bihVersion) async {
    await pullLatestReleaseGH("cobwebsh/BepInHecks", "bepinhecks-dl",
        version: bihVersion == "" ? "latest" : bihVersion);
    var instDir = p.join(SettingsTabState.instPath, id);

    var dir = Directory(instDir);
    if (dir.existsSync()) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, subDialogSetState) {
              return const AlertDialog(
                title: Text("Error"),
                content: Text("An instance with that ID already exists"),
              );
            });
          });
      return;
    }
    dir.createSync();
    copyPath("bepinhecks-dl", instDir);

    var actualVersion = "";
    if (bihVersion != "latest") {
      actualVersion = bihVersion;
    } else {
      var query =
          Uri.parse("https://api.github.com/repos/cobwebsh/BepInHecks/tags");
      Map<String, String> headers = HashMap();
      headers.putIfAbsent("Accept", () => "application/json");
      var response = await http.get(query, headers: headers);
      String jsonText = response.body;
      final json = jsonDecode(jsonText);
      actualVersion = json[0]["name"];
    }

    MyApp.cfg.addInstance(name, id, actualVersion);
  }

  List<Widget> generateCards() {
    List<Widget> out = List.empty(growable: true);

    out.add(Card(
      color: Colors.indigo[100],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.icecream),
            title: Text("Vanilla (${SettingsTabState.gameType})"),
            subtitle: Text(SettingsTabState.gamePath),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  switchVanilla();
                  selectedInstance = "vanilla";
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.amber),
                    foregroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.white)),
                child: const Text("Select"),
              ),
              const Text(" \n "),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    ));

    var instances = MyApp.cfg.getInstances();
    for (var inst in instances) {
      out.add(
        Card(
          color: Colors.indigo[100],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.interests),
                title: Text(inst["name"]),
                subtitle: Text(
                    "${SettingsTabState.instPath}${Platform.pathSeparator}${inst["id"]}\nBepInHecks version: ${inst["version"]}"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      handleModsClick(inst["id"]);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.amber),
                        foregroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.white)),
                    child: const Text("Mods"),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      handleLaunchClick(inst["id"]);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.amber),
                        foregroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.white)),
                    child: const Text("Select"),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      handleDeleteClick(inst["id"]);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.amber),
                        foregroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.white)),
                    child: const Text("Delete"),
                  ),
                  const Text(" \n "),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      );
    }

    out.add(Card(
      color: Colors.indigo[100],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () {
                handleAddClick();
              },
            ),
          )
        ],
      ),
    ));

    return out;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(crossAxisCount: 2, children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: generateCards(),
          ),
        ),
      )
    ]);
  }
}
