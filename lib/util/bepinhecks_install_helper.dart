import "package:http/http.dart" as http;
import "dart:convert";
import "dart:collection";
import "dart:io";
import "package:archive/archive.dart";

Future<void> pullLatestReleaseGH(String repo, String outDir,
    {String version = "latest"}) async {
  String apiQuery = "";
  if (version == "latest") {
    apiQuery = "https://api.github.com/repos/$repo/releases/latest";
  } else {
    apiQuery = "https://api.github.com/repos/$repo/releases/tags/$version";
  }
  Map<String, String> headers = HashMap();
  headers.putIfAbsent("Accept", () => "application/json");

  http.Response response =
      await http.get(Uri.parse(apiQuery), headers: headers);
  String jsonText = response.body;
  final json = jsonDecode(jsonText);
  String releaseAssetUrl = json["assets"][0]["browser_download_url"];

  http.Response assetRaw = await http.get(Uri.parse(releaseAssetUrl));
  final dlBytes = assetRaw.bodyBytes;
  final archive = ZipDecoder().decodeBytes(dlBytes);
  String zipOutDir = outDir;

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
