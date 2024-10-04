import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_browser/src/components/cursor_painter.dart';
import 'package:flutter_browser/src/components/header_browser.dart';
import 'package:flutter_browser/src/types/key_map.dart';
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

  final String _homePage = 'https://google.com';
  final KeyMap _keyMap = KeyMap();
  final double _velocity = 5.0;

  double _dx = 0;
  double _dy = 0;
  double _maxWidth = 0;
  double _maxHeigth = 0;

  bool _showCursor = false;

  final List<String> _console = [];

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
      ..setNavigationDelegate(
        NavigationDelegate(
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
        final prefix = "[${message.level.name.toUpperCase()}}]";
        setState(() {
          _console.add("$prefix: ${message.message}");
        });
      })
      ..loadRequest(Uri.parse(_homePage));
  }

  void _setupCursor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.sizeOf(context);
      setState(() {
        _dx = size.width / 2;
        _dy = size.height / 2;
        _showCursor = true;
      });
    });
  }

  void _cursorClick() {
    _controller.runJavaScriptReturningResult('''
      var element = document.elementFromPoint($_dx, $_dy);
      if (element) element.click();
    ''');
  }

  void _cursorMove() {
    Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (_keyMap.keyLeft && _dx >= 0) {
        _dx -= _velocity;
      } else if (_keyMap.keyRight && _dx < _maxWidth - 15) {
        _dx += _velocity;
      } else if (_keyMap.keyUp && _dy >= 0) {
        _dy -= _velocity;
      } else if (_keyMap.keyDown && _dy < _maxHeigth) {
        _dy += _velocity;
      } else {
        t.cancel();
      }

      setState(() {});
    });
  }

  void _scrollOffset() async {
    var scroll = await _controller.getScrollPosition();

    if (_keyMap.keyUp && _dy <= 0 && scroll.dy > 0) {
      _controller.scrollTo(
        scroll.dx.toInt(),
        scroll.dy.toInt() - 20,
      );
    } else if (_keyMap.keyDown && _dy >= _maxHeigth) {
      _controller.scrollTo(
        scroll.dx.toInt(),
        scroll.dy.toInt() + 20,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCursor();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBrowser(
        homePage: _homePage,
        webViewController: _controller,
        editingController: _editingController,
      ),
      body: LayoutBuilder(
        builder: (context, constrants) {
          _maxWidth = constrants.maxWidth;
          _maxHeigth = constrants.maxHeight;
          return FocusScope(
            autofocus: true,
            onKeyEvent: _keyListener,
            child: Stack(
              children: [
                WebViewWidget(
                  controller: _controller,
                ),
                Positioned(
                  top: _dy,
                  left: _dx,
                  child: CustomPaint(
                    size: const Size(15, 25),
                    painter: CursorPainter(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConsole() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      height: _maxHeigth * 0.4,
      width: _maxWidth,
      color: Colors.grey.shade900,
      child: ListView(
        children: _console.map((c) {
          var style = TextStyle(
            color: c.contains("ERROR") ? Colors.red.shade300 : Colors.white,
          );
          return Text(c, style: style);
        }).toList(),
      ),
    );
  }

  KeyEventResult _keyListener(FocusNode node, KeyEvent event) {
    final pressed = HardwareKeyboard.instance.isLogicalKeyPressed(
      event.logicalKey,
    );

    if (event.logicalKey == LogicalKeyboardKey.select) {
      if (!pressed) {
        _cursorClick();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _keyMap.keyUp = pressed;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _keyMap.keyDown = pressed;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _keyMap.keyLeft = pressed;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _keyMap.keyRight = pressed;
    }

    if (_keyMap.anyPressed) {
      _cursorMove();
      _scrollOffset();
    }

    return KeyEventResult.handled;
  }
}
