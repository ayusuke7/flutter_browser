import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HeaderBrowser extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController editingController;
  final WebViewController webViewController;
  final List<Widget> actions;

  const HeaderBrowser({
    super.key,
    required this.webViewController,
    required this.editingController,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      color: Colors.grey.shade800,
      child: FocusScope(
        onFocusChange: (value) {
          print("HEADER FOCUS $value");
        },
        child: Row(
          children: [
            FutureBuilder<bool>(
              future: webViewController.canGoBack(),
              builder: (context, snap) {
                VoidCallback? onPressed;
                if (snap.data == true) {
                  onPressed = () {
                    webViewController.goBack();
                  };
                }
                return IconButton(
                  color: Colors.white,
                  disabledColor: Colors.grey,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onPressed,
                );
              },
            ),
            FutureBuilder<bool>(
              future: webViewController.canGoForward(),
              builder: (context, snap) {
                VoidCallback? onPressed;
                if (snap.data == true) {
                  onPressed = () {
                    webViewController.goForward();
                  };
                }
                return IconButton(
                  color: Colors.white,
                  disabledColor: Colors.grey,
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: onPressed,
                );
              },
            ),
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.refresh),
              onPressed: () {
                webViewController.reload();
              },
            ),
            Expanded(
              child: TextFormField(
                autofocus: false,
                controller: editingController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) {
                  webViewController.loadRequest(Uri.parse(value));
                },
                decoration: const InputDecoration(
                  filled: true,
                  isDense: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.security),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(40.0),
                    ),
                  ),
                ),
              ),
            ),
            for (var action in actions) action
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
