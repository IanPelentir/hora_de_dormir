import 'package:flutter/material.dart';
import 'dart:async';
import '../models/sleep_model.dart';
import '../services/firebase_service.dart';

class SleepProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  bool _isSleeping = false;
  DateTime? _sleepStartTime;
  Duration _currentDuration = Duration.zero;
  Timer? _timer;

  /// 🧠 PERFIL DO USUÁRIO
  int _age = 30;
  double _sleepGoal = 8.0;

  /// 📊 HISTÓRICO
  List<SleepModel> _history = [];

  /// =========================
  /// GETTERS
  /// =========================
  bool get isSleeping => _isSleeping;
  DateTime? get sleepStartTime => _sleepStartTime;
  Duration get currentDuration => _currentDuration;
  int get age => _age;
  double get sleepGoal => _sleepGoal;
  List<SleepModel> get history => List.unmodifiable(_history);

  /// =========================
  /// 🧠 CONFIGURAÇÕES
  /// =========================
  void setAge(int newAge) {
    if (newAge <= 0) return; // evita idade inválida
    _age = newAge;
    notifyListeners();
  }

  void setSleepGoal(double hours) {
    if (hours <= 0) return; // evita meta inválida
    _sleepGoal = hours;
    notifyListeners();
  }

  /// =========================
  /// 📥 CARREGAR HISTÓRICO DO FIREBASE
  /// =========================
  Future<void> loadHistory() async {
    try {
      final sessions = await _firebaseService.getSleepHistory();
      _history = sessions;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar histórico: $e');
    }
  }

  /// =========================
  /// 🌙 INICIAR SONO
  /// =========================
  void startSleep() {
    if (_isSleeping) return; // evita iniciar duas vezes

    _isSleeping = true;
    _sleepStartTime = DateTime.now();
    _currentDuration = Duration.zero;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_sleepStartTime != null) {
        _currentDuration =
            DateTime.now().difference(_sleepStartTime!);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  /// =========================
  /// ☀️ FINALIZAR SONO
  /// =========================
  Future<void> endSleep() async {
    if (!_isSleeping) return;

    _isSleeping = false;
    _timer?.cancel();

    if (_sleepStartTime != null) {
      final end = DateTime.now();
      final duration = end.difference(_sleepStartTime!);

      if (duration.inMinutes > 0) {
        final session = SleepModel(
          sleepStart: _sleepStartTime!,
          sleepEnd: end,
          duration: duration,
          createdAt: DateTime.now(),
        );

        _history.insert(0, session); // Add ao início (mais recente primeiro)
        
        try {
          await _firebaseService.saveSleepSession(session);
        } catch (e) {
          debugPrint('Erro ao salvar no Firebase: $e');
        }

        /// mantém só últimos 7 registros localmente (no Firebase fica tudo)
        if (_history.length > 7) {
          _history.removeLast();
        }
      }
    }

    notifyListeners();
  }

  /// =========================
  /// 🧹 RESET (IMPORTANTE)
  /// =========================
  void resetCurrentSession() {
    _timer?.cancel();
    _isSleeping = false;
    _sleepStartTime = null;
    _currentDuration = Duration.zero;
    notifyListeners();
  }

  /// =========================
  /// 🎯 STATUS DA META
  /// =========================
  bool reachedGoal(Duration duration) {
    final hours = duration.inMinutes / 60.0;
    return hours >= _sleepGoal;
  }
}