import 'package:flutter/material.dart';
import 'package:flutter_browser/src/components/dev_tools.dart';
import 'package:flutter_browser/src/components/header_browser.dart';
import 'package:flutter_browser/src/components/virtual_mouse.dart';
import 'package:flutter_browser/src/config/web_view_config.dart';
import 'package:flutter_browser/src/provider/config_model.dart';
import 'package:flutter_browser/src/utils/helper.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

const homePage = 'https://google.com';
const userAgent =
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36";

class AppBrowser extends StatefulWidget {
  const AppBrowser({super.key});

  @override
  State<AppBrowser> createState() => _AppBrowserState();
}

class _AppBrowserState extends State<AppBrowser> {
  late final WebViewController _controller;

  final _inputController = TextEditingController();
  final _browserFocus = FocusScopeNode();
  final _headerFocus = FocusScopeNode();
  final _toolsFocus = FocusScopeNode();

  Offset _virtualOffset = Offset.zero;
  Size _virtualSize = Size.zero;

  void _init() {
    _controller = setupWebViewController()
      ..setUserAgent(userAgent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage(_onJavascriptMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: _onUrlChange,
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains("youtube.com")) {
              Helper.openLink(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(homePage));
  }

  void _onJavascriptMessage(JavaScriptConsoleMessage m) {
    final level = m.level.name.toUpperCase();
    final message = "[$level]: ${m.message}\n";
    context.read<ConfigModel>().consoleLog(message);
  }

  void _onUrlChange(UrlChange change) {
    if (change.url != null) {
      _inputController.text = change.url!;
    }
  }

  void _cursorMove(Offset offset, Size size) {
    if (_browserFocus.hasFocus) {
      _virtualOffset = offset;
      _virtualSize = size;
    }
  }

  void _cursorClick(Offset offset) {
    if (_browserFocus.hasFocus) {
      _controller.runJavaScriptReturningResult('''
      var element = document.elementFromPoint(${offset.dx}, ${offset.dy});
      if (element) element.click();
    ''');
    }
  }

  void _scrollOffset(KeyPressed key) async {
    if (!key.keyUp && !key.keyDown) {
      return;
    }

    final scroll = await _controller.getScrollPosition();

    // Check if possible scroll and top offset
    if (key.keyUp) {
      if (scroll.dy >= 0 && _virtualOffset.dy <= 0) {
        _controller.scrollTo(
          scroll.dx.toInt(),
          scroll.dy.toInt() - 40,
        );
      } else if (scroll.dy <= 0 && _virtualOffset.dy <= 0 && mounted) {
        _headerFocus.requestScopeFocus();
      }

      // Check if possible scroll and bottom offset
    } else if (key.keyDown && _virtualOffset.dy >= _virtualSize.height) {
      _controller.scrollTo(
        scroll.dx.toInt(),
        scroll.dy.toInt() + 40,
      );
    }
  }

  bool _validateURL(String url) {
    RegExp urlRegex = RegExp(
        r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');
    return urlRegex.hasMatch(url);
  }

  void _onSubmitted(String value) {
    String url;

    if (_validateURL(value)) {
      url = value.startsWith("http") ? value : "https://$value";
    } else {
      url = "https://www.google.com/search?q=$value";
    }

    _controller.loadRequest(Uri.parse(url));
    _browserFocus.requestScopeFocus();
  }

  void _showDevTools() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: BrowserDevTools(
            node: _toolsFocus,
            onSubmit: _controller.runJavaScript,
            actions: [
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.clear_all),
                onPressed: () {
                  context.read<ConfigModel>().consoleClear();
                },
              )
            ],
          ),
        );
      },
    );
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
          node: _headerFocus,
          controller: _controller,
          inputController: _inputController,
          onSubmitted: _onSubmitted,
          actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.home),
              onPressed: () {
                _controller.loadRequest(Uri.parse(homePage));
              },
            ),
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.settings),
              onPressed: _showDevTools,
            ),
            IconButton(
              color: const Color.fromRGBO(255, 255, 255, 1),
              icon: const Icon(Icons.language),
              onPressed: () {
                _browserFocus.requestFocus();
              },
            ),
          ],
        ),
        body: VirtualMouse(
          node: _browserFocus,
          onClick: _cursorClick,
          onMoveEnd: _cursorMove,
          onKeyPressed: _scrollOffset,
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
