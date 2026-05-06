import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/sleep_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> saveSleepSession(SleepModel session) async {
    final user = currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sleep_sessions')
        .add(session.toMap());
  }

  Future<List<SleepModel>> getSleepHistory() async {
    final user = currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sleep_sessions')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return SleepModel.fromMap(doc.data());
    }).toList();
  }
}