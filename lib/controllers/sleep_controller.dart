import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sleep_model.dart';

class SleepController extends ChangeNotifier {
  final List<SleepModel> _sleepList = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<SleepModel> get sleepList => List.unmodifiable(_sleepList);

  static const double _minIdeal = 7.0;
  static const double _maxIdeal = 9.0;

  /// 📥 BUSCAR DADOS DO FIREBASE (Resolve o problema de sumir ao recarregar)
  Future<void> fetchSleepRecords() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Busca apenas os registros do usuário atual (LGPD Compliance)
      final snapshot = await _db
          .collection('sleep_records')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _sleepList.clear();
      for (var doc in snapshot.docs) {
        _sleepList.add(SleepModel.fromMap(doc.data()));
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao buscar dados: $e");
    }
  }

  /// 📤 ADICIONAR E SALVAR NO BACKEND
  Future<void> addSleep(DateTime start, DateTime end, int age) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final duration = calculateDuration(start, end);

    final model = SleepModel(
      userId: user.uid, // Importante para segurança dos dados
      sleepStart: start,
      sleepEnd: end,
      duration: duration,
      createdAt: DateTime.now(),
    );

    try {
      // Salva no Firestore antes de atualizar a lista local
      await _db.collection('sleep_records').add(model.toMap());
      
      _sleepList.insert(0, model);
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao salvar no Firebase: $e");
    }
  }

  // --- MÉTODOS DE LÓGICA (Mantidos e Refinados) ---

  static String getSleepQualityFeedback(Duration duration) {
    final hours = duration.inMinutes / 60.0;
    if (hours <= 0) return "Sem dados";
    if (hours < 6) return "Sono ruim 😴";
    if (hours < _minIdeal) return "Precisa melhorar ⚠️";
    if (hours <= _maxIdeal) return "Sono bom ✅";
    if (hours <= 10) return "Recuperação excelente 💪";
    return "Sono excessivo 💤";
  }

  static String getRecommendedSleep(int age) {
    if (age < 18) return "8–10h";
    if (age <= 64) return "7–9h";
    return "7–8h";
  }

  static double getIdealSleepHours(int age) {
    if (age < 18) return 9;
    if (age <= 64) return 8;
    return 7.5;
  }

  static bool didMeetGoal(SleepModel model, int age) {
    final hours = model.duration.inMinutes / 60.0;
    final ideal = getIdealSleepHours(age);
    return hours >= (ideal - 1) && hours <= (ideal + 1);
  }

  static Duration calculateDuration(DateTime start, DateTime end) {
    return end.isBefore(start)
        ? end.add(const Duration(days: 1)).difference(start)
        : end.difference(start);
  }
}