import 'package:url_launcher/url_launcher_string.dart';

abstract class Helper {
  static Future<bool> openLauncher(String scheme) async {
    if (await canLaunchUrlString(scheme)) {
      return await launchUrlString(scheme);
    }

    return Future.value(false);
  }

  static Future<bool> openLink(String url) async {
    return openLauncher(url);
  }

  static Future<bool> openFile(String path) {
    final Uri uri = Uri.file(path);
    return openLauncher(uri.toString());
  }
}
