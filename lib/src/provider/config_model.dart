import 'package:flutter/material.dart';

class ConfigModel extends ChangeNotifier {
  final String _homePage = 'https://google.com';
  List<String> _console = [];

  String get homePage => _homePage;
  List<String> get console => _console;

  void consoleLog(String message) {
    _console = List<String>.of(_console)..add(message);
    notifyListeners();
  }

  void consoleClear() {
    _console.clear();
    notifyListeners();
  }
}
