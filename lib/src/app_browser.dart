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
  final _headerFocus = FocusScopeNode();
  final _mouseFocus = FocusScopeNode();
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
    final level = m.level.name;
    final message = "[$level]: ${m.message}\n";
    context.read<ConfigModel>().log(message);
  }

  void _onUrlChange(UrlChange change) {
    if (change.url != null) {
      _inputController.text = change.url!;
    }
  }

  void _cursorMove(Offset offset, Size size) {
    _virtualOffset = offset;
    _virtualSize = size;
  }

  void _cursorClick(Offset offset) {
    _controller.runJavaScript('''
      var element = document.elementFromPoint(${offset.dx}, ${offset.dy});
      console.log(${offset.dx}, ${offset.dy});
      console.log(element.innerHTML);
      if (element) element.click();
    ''');
  }

  void _scrollOffset(KeyPressed key) async {
    if (!key.keyUp && !key.keyDown) return;

    final scroll = await _controller.getScrollPosition();

    // Check if possible scroll and top offset
    if (key.keyUp && _virtualOffset.dy <= 0) {
      if (scroll.dy >= 0) {
        _controller.scrollTo(
          scroll.dx.toInt(),
          scroll.dy.toInt() - 40,
        );
      } else {
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

  void _onSubmitted(String value) {
    String url;

    if (Helper.isURL(value)) {
      url = value.startsWith("http") ? value : "https://$value";
    } else {
      url = "https://www.google.com/search?q=$value";
    }

    _controller.loadRequest(Uri.parse(url));
    _mouseFocus.requestScopeFocus();
  }

  void _showDevTools() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: BrowserDevTools(
            node: _toolsFocus,
            onSubmit: (value) {
              if (value.isNotEmpty) {
                _controller.runJavaScript(value);
              }
            },
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
                  context.read<ConfigModel>().clear();
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
  void dispose() {
    _inputController.dispose();
    super.dispose();
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
              color: Colors.white,
              icon: const Icon(Icons.language),
              onPressed: () {
                _mouseFocus.requestFocus();
              },
            ),
          ],
        ),
        body: VirtualMouse(
          autoFocus: true,
          node: _mouseFocus,
          onClick: _cursorClick,
          onMoveEnd: _cursorMove,
          onKeyPressed: _scrollOffset,
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
