import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseService.currentUser != null;

  /// 🔐 LOGIN AUTOMÁTICO
  Future<void> initAuth() async {
    if (_firebaseService.currentUser == null) {
      _isLoading = true;
      notifyListeners();

      await _firebaseService.signInAnonymously();

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _firebaseService.signOut();
    notifyListeners();
  }
}