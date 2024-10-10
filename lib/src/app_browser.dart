import 'package:flutter/material.dart';
import 'package:flutter_browser/src/components/dev_tools.dart';
import 'package:flutter_browser/src/components/header_browser.dart';
import 'package:flutter_browser/src/components/virtual_mouse.dart';
import 'package:flutter_browser/src/utils/helper.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

const userAgent =
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36";

class AppBrowser extends StatefulWidget {
  const AppBrowser({super.key});

  @override
  State<AppBrowser> createState() => _AppBrowserState();
}

class _AppBrowserState extends State<AppBrowser> {
  late final WebViewController _controller;

  final _editingController = TextEditingController();
  final String _homePage = 'https://flutter.dev';
  final List<String> _console = [];

  Offset _virtualOffset = Offset.zero;
  Size _virtualSize = Size.zero;
  bool _showConsole = false;

  WebViewController _setup() {
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

  void _init() {
    _controller = _setup()
      ..setUserAgent(userAgent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnScrollPositionChange((position) {})
      ..setNavigationDelegate(
        NavigationDelegate(
          onHttpAuthRequest: (request) {},
          onNavigationRequest: (request) {
            if (request.url.contains("youtube.com")) {
              Helper.openLink(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            if (change.url != null) {
              _editingController.text = change.url!;
            }
          },
        ),
      )
      ..setOnConsoleMessage((message) {
        final level = message.level.name.toUpperCase();
        setState(() {
          _console.add("[$level]: ${message.message}\n");
        });
      })
      ..loadRequest(Uri.parse(_homePage));
  }

  void _cursorClick(Offset offset) {
    _controller.runJavaScriptReturningResult('''
      var element = document.elementFromPoint(${offset.dx}, ${offset.dy});
      if (element) element.click();
    ''');
  }

  void _scrollOffset(KeyPressed key) async {
    if (!key.keyUp && !key.keyDown) return;

    final scroll = await _controller.getScrollPosition();

    // Check if possible scroll and top offset
    if (key.keyUp) {
      if (scroll.dy >= 0 && _virtualOffset.dy <= 0) {
        _controller.scrollTo(
          scroll.dx.toInt(),
          scroll.dy.toInt() - 40,
        );
      } else if (scroll.dy <= 0 && _virtualOffset.dy <= 0 && mounted) {
        FocusScope.of(context).previousFocus();
      }

      // Check if possible scroll and bottom offset
    } else if (key.keyDown && _virtualOffset.dy >= _virtualSize.height) {
      _controller.scrollTo(
        scroll.dx.toInt(),
        scroll.dy.toInt() + 40,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: Scaffold(
        appBar: HeaderBrowser(
          webViewController: _controller,
          editingController: _editingController,
          actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.home),
              onPressed: () {
                _controller.loadRequest(
                  Uri.parse(_homePage),
                );
              },
            ),
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.settings),
              onPressed: () {
                setState(() {
                  _showConsole = !_showConsole;
                });
              },
            ),
          ],
        ),
        body: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            VirtualMouse(
              onClick: _cursorClick,
              onKeyPressed: _scrollOffset,
              onMoveEnd: (offset, size) {
                _virtualOffset = offset;
                _virtualSize = size;
              },
              child: WebViewWidget(
                controller: _controller,
              ),
            ),
            if (_showConsole)
              BrowserDevTools(
                console: _console,
                onSubmit: _controller.runJavaScript,
                onClear: () {
                  setState(() {
                    _console.clear();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
