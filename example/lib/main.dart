import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import 'gallery/gallery_home.dart';

void main() {
  runApp(const D3ExampleApp());
}

class D3ExampleApp extends StatefulWidget {
  const D3ExampleApp({super.key});

  @override
  State<D3ExampleApp> createState() => _D3ExampleAppState();
}

class _D3ExampleAppState extends State<D3ExampleApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'd3 Design System',
      debugShowCheckedModeBanner: false,
      theme: D3AppTheme.light(),
      darkTheme: D3AppTheme.dark(),
      themeMode: _themeMode,
      home: GalleryHome(
        themeMode: _themeMode,
        onToggleTheme: () => setState(() {
          _themeMode =
              _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        }),
      ),
    );
  }
}
