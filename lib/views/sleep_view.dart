import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/sleep_provider.dart';
import '../providers/auth_provider.dart';
import '../controllers/sleep_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/sleep_card.dart';
import '../widgets/sleep_chart.dart';
import 'history_view.dart';
import 'auth_view.dart';

class SleepView extends StatefulWidget {
  const SleepView({super.key});

  @override
  State<SleepView> createState() => _SleepViewState();
}

class _SleepViewState extends State<SleepView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Animação pulsante para o ícone durante o sono
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ✅ Fade-in ao abrir a tela
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeInAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    );

    // ✅ Animação de "respiração" para o glow ring
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // Carrega o histórico do Firebase ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeInController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inMinutes == 0) {
      return "${seconds}s";
    }
    return "${hours}h ${minutes}m";
  }

  void _showFeedbackSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showGoalDialog(Duration duration) {
    final provider = context.read<SleepProvider>();
    final reachedGoal = provider.reachedGoal(duration);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2A4A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              reachedGoal ? Icons.emoji_events : Icons.info_outline,
              color: reachedGoal ? Colors.amber : Colors.white70,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              reachedGoal ? "Parabéns! 🎉" : "Sessão Registrada",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Você dormiu ${_formatDuration(duration)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reachedGoal
                  ? "Você atingiu sua meta de ${provider.sleepGoal.toStringAsFixed(1)}h! Continue assim! 💪"
                  : "Sua meta é ${provider.sleepGoal.toStringAsFixed(1)}h. Tente dormir mais na próxima vez!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: reachedGoal ? Colors.greenAccent : Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              SleepController.getSleepQualityFeedback(duration),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(color: Colors.indigoAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();
    final isSleeping = provider.isSleeping;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de Sono'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HistoryView(),
                  transitionsBuilder: (_, a, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1B2A4A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Sair", style: TextStyle(color: Colors.white)),
                  content: const Text(
                    "Deseja realmente sair da sua conta?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Sair", style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                if (!context.mounted) return;
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthView()),
                );
              }
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                /// 🌙 TÍTULO ANIMADO
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    isSleeping ? "Monitorando seu sono..." : "Pronto para dormir?",
                    key: ValueKey(isSleeping),
                    style: const TextStyle(fontSize: 26, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                /// 🛏 CARD PRINCIPAL COM ANIMAÇÃO
                AnimatedBuilder(
                  animation: _breatheAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: isSleeping
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigoAccent
                                      .withOpacity(_breatheAnimation.value * 0.5),
                                  blurRadius: 30 + (_breatheAnimation.value * 20),
                                  spreadRadius: _breatheAnimation.value * 8,
                                ),
                              ],
                            )
                          : null,
                      child: child,
                    );
                  },
                  child: SleepCard(
                    child: Column(
                      children: [
                        // Ícone animado durante sono
                        if (isSleeping)
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: child,
                              );
                            },
                            child: const Icon(
                              Icons.nights_stay,
                              size: 80,
                              color: Colors.amberAccent,
                            ),
                          )
                        else
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(scale: value, child: child);
                            },
                            child: const Icon(
                              Icons.bed,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),

                        const SizedBox(height: 16),

                        if (isSleeping) ...[
                          const Text(
                            "Sessão atual",
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          // ✅ Timer grande com estilo monoespaçado
                          Text(
                            _formatDuration(provider.currentDuration),
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // ✅ Barra de progresso da meta
                          _buildGoalProgress(provider),
                        ] else ...[
                          const Text(
                            "Último sono",
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              provider.lastSessionDuration.inSeconds > 0
                                  ? _formatDuration(provider.lastSessionDuration)
                                  : "Nenhum registro",
                              key: ValueKey(provider.lastSessionDuration.inSeconds),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: provider.lastSessionDuration.inSeconds > 0
                                    ? Colors.white
                                    : Colors.white38,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// 🎯 CONFIGURAÇÕES (IDADE + META) — com animação de entrada
                if (!isSleeping) ...[
                  _buildAnimatedCard(
                    delay: 0,
                    child: SleepCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.white54, size: 20),
                              const SizedBox(width: 8),
                              const Text("Sua idade", style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Slider(
                            value: provider.age.toDouble(),
                            min: 10,
                            max: 80,
                            divisions: 70,
                            label: provider.age.toString(),
                            activeColor: Colors.indigoAccent,
                            onChanged: (value) {
                              provider.setAge(value.toInt());
                            },
                          ),
                          Text(
                            "Idade: ${provider.age} anos",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildAnimatedCard(
                    delay: 100,
                    child: SleepCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.flag, color: Colors.white54, size: 20),
                              const SizedBox(width: 8),
                              const Text("Meta de sono", style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Slider(
                            value: provider.sleepGoal,
                            min: 4,
                            max: 12,
                            divisions: 16,
                            label: "${provider.sleepGoal}h",
                            activeColor: Colors.indigoAccent,
                            onChanged: (value) {
                              provider.setSleepGoal(value);
                            },
                          ),
                          Text(
                            "Meta: ${provider.sleepGoal.toStringAsFixed(1)} horas",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "Recomendado: ${SleepController.getRecommendedSleep(provider.age)}",
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildAnimatedCard(
                    delay: 200,
                    child: SleepCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bar_chart, color: Colors.white54, size: 20),
                              const SizedBox(width: 8),
                              const Text("Últimos 7 dias", style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: provider.history.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.nights_stay, size: 48, color: Colors.white24),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Nenhum dado ainda.\nComece a registrar seu sono!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white38, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  )
                                : SleepChart(weeklyHistory: provider.history),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                /// ▶️ BOTÃO PRINCIPAL COM ANIMAÇÃO
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: CustomButton(
                    text: isSleeping ? "Acordar ☀️" : "Dormir 🌙",
                    icon: isSleeping ? Icons.wb_sunny : Icons.nightlight_round,
                    color: isSleeping ? Colors.orange : Colors.indigo,
                    onPressed: () async {
                      if (isSleeping) {
                        // Captura a duração antes de parar
                        final duration = provider.currentDuration;
                        await provider.endSleep();

                        if (!context.mounted) return;

                        // ✅ Feedback visual
                        _showFeedbackSnackBar(
                          "Sessão salva: ${_formatDuration(duration)}",
                          Icons.check_circle,
                          Colors.green.shade700,
                        );

                        // ✅ Mostra diálogo de feedback se dormiu mais de 10 segundos
                        if (duration.inSeconds > 10) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) _showGoalDialog(duration);
                          });
                        }
                      } else {
                        provider.startSleep();
                        _showFeedbackSnackBar(
                          "Boa noite! Monitorando seu sono...",
                          Icons.nights_stay,
                          Colors.indigo.shade700,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Barra de progresso da meta durante o sono
  Widget _buildGoalProgress(SleepProvider provider) {
    final goalSeconds = provider.sleepGoal * 3600;
    final currentSeconds = provider.currentDuration.inSeconds.toDouble();
    final progress = (currentSeconds / goalSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.greenAccent : Colors.indigoAccent,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${(progress * 100).toStringAsFixed(0)}% da meta de ${provider.sleepGoal.toStringAsFixed(1)}h",
          style: TextStyle(
            color: progress >= 1.0 ? Colors.greenAccent : Colors.white38,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// ✅ Card com animação de entrada escalonada
  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }
}