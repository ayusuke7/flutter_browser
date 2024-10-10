import 'package:flutter/material.dart';

class BrowserDevTools extends StatelessWidget {
  final List<String> console;

  final VoidCallback onClear;
  final Function(String) onSubmit;

  const BrowserDevTools({
    super.key,
    required this.onSubmit,
    required this.onClear,
    this.console = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.4,
      color: Colors.grey.shade900,
      child: FocusScope(
        autofocus: true,
        child: Row(
          children: [
            Expanded(
              child: ListView(
                children: console.map((text) {
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
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.3,
              child: TextField(
                maxLines: 7,
                autofocus: false,
                onSubmitted: onSubmit,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Console:",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
