import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sleep_model.dart';
import '../services/firebase_service.dart';

class SleepProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSleeping = false;
  DateTime? _sleepStartTime;
  Duration _currentDuration = Duration.zero;
  Timer? _timer;
  bool _isLoading = false;

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
  bool get isLoading => _isLoading;
  List<SleepModel> get history => List.unmodifiable(_history);

  /// =========================
  /// 📥 CARREGAR HISTÓRICO
  /// =========================
  Future<void> loadHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      _history = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final sessions = await _firebaseService.getSleepHistory();
      _history = sessions;
    } catch (e) {
      debugPrint('Erro ao carregar histórico: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// 🌙 CONTROLE DE SONO
  /// =========================
  void startSleep() {
    if (_isSleeping) return;

    _isSleeping = true;
    _sleepStartTime = DateTime.now();
    _currentDuration = Duration.zero;

    _timer?.cancel();
    
    // ✅ CORREÇÃO: Timer alterado para 1 segundo para atualização em tempo real na UI
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_sleepStartTime != null) {
        _currentDuration = DateTime.now().difference(_sleepStartTime!);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  Future<void> endSleep() async {
    if (!_isSleeping) return;

    final user = _auth.currentUser;
    if (user == null) return;

    _isSleeping = false;
    _timer?.cancel();

    if (_sleepStartTime != null) {
      final end = DateTime.now();
      final duration = end.difference(_sleepStartTime!);

      // ✅ CORREÇÃO: Permitir salvar registros com mais de 1 segundo (útil para testes)
      if (duration.inSeconds > 0) {
        final session = SleepModel(
          userId: user.uid,
          sleepStart: _sleepStartTime!,
          sleepEnd: end,
          duration: duration, // Passa a duration real calculada
          createdAt: DateTime.now(),
        );

        _history.insert(0, session); 
        
        try {
          await _firebaseService.saveSleepSession(session);
        } catch (e) {
          debugPrint('Erro ao salvar no Firebase: $e');
        }
      }
    }
    
    // Limpa a sessão atual após salvar
    _sleepStartTime = null;
    _currentDuration = Duration.zero;
    
    notifyListeners();
  }

  /// =========================
  /// 🧠 CONFIGURAÇÕES E UTILITÁRIOS
  /// =========================
  void setAge(int newAge) {
    if (newAge > 0) {
      _age = newAge;
      notifyListeners();
    }
  }

  void setSleepGoal(double hours) {
    if (hours > 0) {
      _sleepGoal = hours;
      notifyListeners();
    }
  }

  void resetCurrentSession() {
    _timer?.cancel();
    _isSleeping = false;
    _sleepStartTime = null;
    _currentDuration = Duration.zero;
    notifyListeners();
  }

  /// 🎯 STATUS DA META (Baseado em horas decimais)
  bool reachedGoal(Duration duration) {
    final hours = duration.inSeconds / 3600.0;
    return hours >= _sleepGoal;
  }
}