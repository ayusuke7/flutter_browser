import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_browser/src/app_browser.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App Browser',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
          focusColor: Colors.deepPurple,
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                if (states.contains(WidgetState.focused)) {
                  return Colors.white.withOpacity(.5);
                }
                return Colors.transparent;
              }),
            ),
          ),
        ),
        home: const AppBrowser(),
      ),
    );
  }
}
