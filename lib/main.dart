import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'di/service_locator.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'viewmodels/health_viewmodel.dart';
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification service
  await NotificationService().initialize();

  setupDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<HealthViewModel>()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'PulseNote',
      theme: themeProvider.themeData,
      darkTheme: themeProvider.themeData,
      themeMode: ThemeMode.dark, // Always dark mode for cyberpunk
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
