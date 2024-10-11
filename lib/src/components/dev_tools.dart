import 'package:flutter/material.dart';
import 'package:flutter_browser/src/provider/config_model.dart';
import 'package:provider/provider.dart';

class BrowserDevTools extends StatelessWidget {
  final Function(String) onSubmit;

  final FocusScopeNode? node;
  final List<Widget> actions;

  const BrowserDevTools({
    super.key,
    required this.onSubmit,
    this.actions = const [],
    this.node,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConfigModel>();
    final consoleWidget = Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: provider.console.map((text) {
              return Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 10, 10),
          child: TextField(
            onSubmitted: onSubmit,
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.play_arrow),
              hintText: 'console.log("Hello World");',
            ),
          ),
        ),
      ],
    );

    Widget child;

    if (actions.isNotEmpty) {
      child = Row(
        children: [
          Expanded(
            child: consoleWidget,
          ),
          Container(
            width: 50.0,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey),
              ),
            ),
            child: Column(children: actions),
          )
        ],
      );
    } else {
      child = consoleWidget;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: const Border(
          top: BorderSide(color: Colors.grey),
        ),
      ),
      child: FocusScope(
        node: node,
        child: child,
      ),
    );
  }
}
