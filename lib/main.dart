import 'package:flutter/material.dart';
import 'package:flutter_browser/src/app_widget.dart';
import 'package:flutter_browser/src/provider/config_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => ConfigModel(),
    child: const AppWidget(),
  ));
}
