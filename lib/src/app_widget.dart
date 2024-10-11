import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_browser/src/app_browser.dart';
import 'package:flutter_browser/src/provider/config_model.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConfigModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App Browser',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.focused)) {
                  return Colors.white.withOpacity(.5);
                }
                return Colors.transparent;
              }),
            ),
          ),
        ),
        home: Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
          },
          child: const AppBrowser(),
        ),
      ),
    );
  }
}
