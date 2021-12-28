import 'package:flutter/material.dart';
import 'package:qr_ar/configs/theme_config.dart';
import 'package:qr_ar/screens/home/home_screen.dart';
import 'package:qr_ar/ui/home_view.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeView(),
      theme: ThemeConfig(false).themeData,
      darkTheme: ThemeConfig(true).themeData,
      themeMode: ThemeMode.system,
    );
  }
}
