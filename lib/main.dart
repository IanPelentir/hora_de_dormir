import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔥 GERADO PELO FLUTTERFIRE CLI
import 'firebase_options.dart';

import 'providers/sleep_provider.dart';
import 'providers/auth_provider.dart'; // ✅ ADICIONADO
import 'views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Erro ao inicializar Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()), // ✅ AQUI
      ],
      child: const SleepTrackerApp(),
    );
  }
}

class SleepTrackerApp extends StatelessWidget {
  const SleepTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color deepBlue = Color(0xFF0D1B2A);
    const Color indigoAccents = Color(0xFF3F51B5);

    return MaterialApp(
      title: 'Sleep Tracker',
      debugShowCheckedModeBanner: false,

      locale: const Locale('pt', 'BR'),

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deepBlue,

        colorScheme: const ColorScheme.dark(
          primary: indigoAccents,
          surface: Color(0xFF1B2A4A),
          background: deepBlue,
        ),

        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          displayLarge: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: deepBlue,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),

        useMaterial3: true,
      ),

      home: const SplashView(),
    );
  }
}