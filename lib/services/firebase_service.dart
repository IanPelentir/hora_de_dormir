import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Para o debugPrint
import '../models/sleep_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      debugPrint('Erro ao entrar anonimamente: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 💾 Salva a sessão de sono
  Future<void> saveSleepSession(SleepModel session) async {
    final user = currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleep_sessions')
          .add(session.toMap());
    } catch (e) {
      debugPrint('Erro ao salvar no Firestore: $e');
      rethrow;
    }
  }

  /// 📥 Recupera o histórico de sono
  Future<List<SleepModel>> getSleepHistory() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleep_sessions')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // DEBUG: Descomente a linha abaixo se o tempo continuar zerado
        // debugPrint('Dados do Firebase: $data');

        return SleepModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Erro ao buscar histórico no Firestore: $e');
      return [];
    }
  }
}