import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

WebViewController setupWebViewController() {
  late final PlatformWebViewControllerCreationParams params;
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    params = WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{
        PlaybackMediaTypes.audio,
        PlaybackMediaTypes.video,
      },
    );
  } else {
    params = const PlatformWebViewControllerCreationParams();
  }

  return WebViewController.fromPlatformCreationParams(
    params,
  );
}
