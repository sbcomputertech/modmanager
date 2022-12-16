import "dart:convert";
import "dart:io";

class ModManCfg {
  late Map<String, dynamic> json;

  static ModManCfg load() {
    var cfg = ModManCfg();
    var f = File("modman.json");
    var ftext = f.readAsStringSync();
    cfg.json = jsonDecode(ftext);
    return cfg;
  }

  void write() {
    var f = File("modman.json");
    var text = jsonEncode(json);
    f.writeAsStringSync(text);
  }

  void updateSettings(String part, String key, Object value) {
    var section = "settings";
    json[section][part][key] = value;
    write();
  }

  Object getSetting(String part, String key) {
    var section = "settings";
    return json[section][part][key];
  }

  List<dynamic> getInstances() {
    var section = "instances";
    return json[section];
  }

  void editInstance(id, newVal) {
    var instances = getInstances();
    var inst = getInstanceId(id);
    var index = instances.indexOf(inst);
    json["instances"][index] = newVal;
    write();
  }

  dynamic getInstanceId(String id) {
    var instances = getInstances();
    for (var inst in instances) {
      if (inst["id"] == id) {
        return inst;
      }
    }
  }

  void deleteInstance(String id) {
    var instanceToRemove = getInstanceId(id);
    (json["instances"] as List<dynamic>).remove(instanceToRemove);
    write();
  }

  void addInstance(String name, String id, String version) {
    dynamic newObj = {
      "name": name,
      "id": id,
      "version": version,
      "mods": List.empty()
    };
    (json["instances"] as List<dynamic>).add(newObj);
    write();
  }

  void addMod(String name, String id, String version, String instance) {
    dynamic newObj = {
      "name": name,
      "id": id,
      "version": version,
    };
    var modlist = List.empty(growable: true);
    var currMods = json["instances"]
            [getInstances().indexOf(getInstanceId(instance))]["mods"]
        as List<dynamic>;
    for (var currMod in currMods) {
      modlist.add(modlist);
    }
    modlist.add(newObj);
    json["instances"][getInstances().indexOf(getInstanceId(instance))]["mods"] =
        modlist;
    write();
  }

  int getStatInt(String name) {
    return json["stats"][name] as int;
  }

  String getStatString(String name) {
    return json["stats"][name] as String;
  }

  void setStat(String name, dynamic value) {
    json["stats"][name] = value;
    write();
  }
}
