import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 🔐 LOGIN
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// 📝 CADASTRO + SALVA NO FIRESTORE (AQUI ESTAVA O PROBLEMA)
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// 🕵️ LOGIN ANÔNIMO
  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      final user = credential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'anonymous': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// 🚪 LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// ⚠️ ERROS
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Nenhum usuário encontrado com este e-mail.');
      case 'wrong-password':
        return Exception('Senha incorreta.');
      case 'invalid-email':
        return Exception('E-mail inválido.');
      case 'email-already-in-use':
        return Exception('E-mail já está em uso.');
      case 'weak-password':
        return Exception('Senha muito fraca.');
      default:
        return Exception(e.message ?? 'Erro desconhecido.');
    }
  }
}