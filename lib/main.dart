import 'package:flutter/material.dart';
import 'ui/theme.dart';
import 'ui/screens/dashboard_screen.dart';

void main() {
  runApp(const BackgroundRemoverApp());
}

class BackgroundRemoverApp extends StatelessWidget {
  const BackgroundRemoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Remover',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}
