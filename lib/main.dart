import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 🔥 GERADO PELO FLUTTERFIRE CLI
import 'firebase_options.dart';

// Importe o arquivo onde a classe SleepProvider está definida
import 'providers/sleep_provider.dart'; 
import 'providers/auth_provider.dart';
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
        // lazy: false garante que o login seja verificado IMEDIATAMENTE ao abrir
        ChangeNotifierProvider(create: (_) => AuthProvider(), lazy: false),
        
        // CORREÇÃO: O nome aqui deve ser SleepProvider para coincidir com a View
        ChangeNotifierProvider(create: (_) => SleepProvider()),
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

      // Suporte a PT-BR (Removido o 'const' para evitar erro de inicialização)
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deepBlue,

        colorScheme: const ColorScheme.dark(
          primary: indigoAccents,
          surface: Color(0xFF1B2A4A),
          onSurface: Colors.white,
        ),

        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: deepBlue,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        useMaterial3: true,
      ),

      home: const SplashView(),
    );
  }
}