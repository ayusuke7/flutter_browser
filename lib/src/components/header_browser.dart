import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HeaderBrowser extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController editingController;
  final WebViewController webViewController;
  final String homePage;

  const HeaderBrowser({
    super.key,
    required this.webViewController,
    required this.editingController,
    required this.homePage,
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
      child: Row(
        children: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              webViewController.goBack();
            },
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              webViewController.goForward();
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
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.home),
            onPressed: () async {
              if (await webViewController.currentUrl() != homePage) {
                webViewController.loadRequest(Uri.parse(homePage));
              }
            },
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController.reload();
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
