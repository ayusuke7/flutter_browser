import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HeaderBrowser extends StatelessWidget implements PreferredSizeWidget {
  final WebViewController controller;
  final List<Widget> actions;
  final FocusScopeNode? node;
  final TextEditingController? inputController;

  final Function(String)? onSubmitted;

  const HeaderBrowser({
    super.key,
    required this.controller,
    this.inputController,
    this.actions = const [],
    this.node,
    this.onSubmitted,
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
        node: node,
        child: Row(
          children: [
            FutureBuilder<bool>(
              future: controller.canGoBack(),
              builder: (context, snap) {
                VoidCallback? onPressed;
                if (snap.data == true) {
                  onPressed = () {
                    controller.goBack();
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
              future: controller.canGoForward(),
              builder: (context, snap) {
                VoidCallback? onPressed;
                if (snap.data == true) {
                  onPressed = () {
                    controller.goForward();
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
                controller.reload();
              },
            ),
            Expanded(
              child: TextFormField(
                autofocus: false,
                controller: inputController,
                onFieldSubmitted: onSubmitted,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
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
  Size get preferredSize => const Size.fromHeight(70.0);
}
