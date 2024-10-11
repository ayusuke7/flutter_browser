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

  static bool isURL(String url) {
    RegExp urlRegex = RegExp(
        r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');
    return urlRegex.hasMatch(url);
  }
}
