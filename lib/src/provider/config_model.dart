import 'package:flutter/material.dart';

class ConfigModel extends ChangeNotifier {
  final String _homePage = 'https://google.com';
  final List<String> _console = [];

  String get homePage => _homePage;
  List<String> get console => _console;

  void log(String message) {
    _console.add(message);
    notifyListeners();
  }

  void clear() {
    _console.clear();
    notifyListeners();
  }
}
