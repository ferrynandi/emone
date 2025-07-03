import 'package:flutter/material.dart';
import 'ui/home_screen.dart';

void main() => runApp(const EmoneApp());

class EmoneApp extends StatelessWidget {
  const EmoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emone - Pembaca eMoney',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}
