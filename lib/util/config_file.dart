import 'dart:convert';
import 'dart:io';

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
}
