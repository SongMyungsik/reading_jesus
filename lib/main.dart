import 'package:flutter/material.dart';
import 'screen/splash_screen.dart';

void main() {
  runApp(const BibleCalendarApp());
}

class BibleCalendarApp extends StatelessWidget {
  const BibleCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '성경 읽기 달력',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
