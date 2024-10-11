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
              var color = Colors.white;

              if (text.toLowerCase().contains("erro")) {
                color = Colors.red;
              }

              return Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 15.0,
                ),
              );
            }).toList(),
          ),
        ),
        TextField(
          autofocus: false,
          onSubmitted: onSubmit,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'console.log("Hello World");',
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
