import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/sleep_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔐 GET USER ATUAL
  User? get currentUser => _auth.currentUser;

  /// 🔐 LOGIN ANÔNIMO (simples pra começar)
  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// 🚪 LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 💤 SALVAR SESSÃO DE SONO
  Future<void> saveSleepSession(SleepModel session) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sleep_sessions')
        .add({
      'sleepStart': session.sleepStart.toIso8601String(),
      'sleepEnd': session.sleepEnd?.toIso8601String(),
      'duration': session.duration?.inMinutes,
      'createdAt': session.createdAt.toIso8601String(),
    });
  }

  /// 📥 BUSCAR HISTÓRICO
  Future<List<SleepModel>> getSleepHistory() async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sleep_sessions')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return SleepModel(
        sleepStart: DateTime.parse(data['sleepStart']),
        sleepEnd: data['sleepEnd'] != null
            ? DateTime.parse(data['sleepEnd'])
            : null,
        duration: data['duration'] != null
            ? Duration(minutes: data['duration'])
            : null,
        createdAt: DateTime.parse(data['createdAt']),
      );
    }).toList();
  }
}