import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Backend.init();
  runApp(const EmotionalIntelligenceApp());
}

class EmotionalIntelligenceApp extends StatelessWidget {
  const EmotionalIntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emostate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Clinical light theme is the product default; switch to
      // ThemeMode.system to follow the device setting.
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
