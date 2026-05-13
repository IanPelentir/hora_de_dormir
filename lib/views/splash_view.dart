import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'auth_view.dart';
import 'sleep_view.dart';
import 'terms_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late AnimationController _starController;
  late AnimationController _progressController;

  // Estrelas decorativas
  final List<_Star> _stars = List.generate(30, (_) => _Star.random());

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fade = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    );

    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack),
    );

    // Animação de estrelas
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Progresso do loading
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _mainController.forward();

    Timer(const Duration(seconds: 3), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    
    final auth = context.read<AuthProvider>();
    
    // Aguarda o auth state changes processar
    int attempts = 0;
    while (auth.isLoading && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      attempts++;
      if (!mounted) return;
    }
    
    Widget nextScreen;

    if (auth.isLoggedIn) {
      if (auth.acceptedTerms) {
        nextScreen = const SleepView();
      } else {
        nextScreen = const TermsView();
      }
    } else {
      nextScreen = const AuthView();
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _starController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF050A18), Color(0xFF0D1B2A), Color(0xFF1A237E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ✅ Estrelas animadas
          AnimatedBuilder(
            animation: _starController,
            builder: (context, _) {
              return CustomPaint(
                painter: _StarPainter(_stars, _starController.value),
                size: Size.infinite,
              );
            },
          ),

          // Conteúdo central
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone com glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5C6BC0).withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.nightlight_round,
                        color: Color(0xFF5C6BC0),
                        size: 110,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Sleep Tracker",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Monitore e melhore seu sono",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // ✅ Barra de progresso elegante
                    SizedBox(
                      width: 200,
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progressController.value,
                              minHeight: 3,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF5C6BC0),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modelo de estrela para o fundo animado
class _Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double initialOpacity;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.initialOpacity,
  });

  factory _Star.random() {
    final rng = Random();
    return _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: rng.nextDouble() * 2.5 + 0.5,
      speed: rng.nextDouble() * 0.5 + 0.5,
      initialOpacity: rng.nextDouble() * 0.5 + 0.3,
    );
  }
}

/// Painter para desenhar estrelas com twinkle
class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double animValue;

  _StarPainter(this.stars, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final opacity = (star.initialOpacity *
              (0.5 + 0.5 * sin(animValue * 2 * pi * star.speed)))
          .clamp(0.0, 1.0);

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => true;
}