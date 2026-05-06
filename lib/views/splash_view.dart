import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sleep_provider.dart';
import 'auth_view.dart';
import 'sleep_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    final sleepProvider = context.read<SleepProvider>();

    await auth.initAuth();
    
    if (auth.isLoggedIn) {
      // Se estiver logado, tenta carregar o histórico
      try {
        await sleepProvider.loadHistory();
      } catch (e) {
        debugPrint('Erro ao carregar histórico: $e');
      }
    }

    if (!mounted) return;

    if (auth.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SleepView()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}