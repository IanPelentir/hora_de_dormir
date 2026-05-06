import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _authService.currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// 🔐 LOGIN AUTOMÁTICO (Caso precise tentar logar anonimamente ou carregar estado inicial)
  Future<void> initAuth() async {
    // Apenas notifica inicialização se precisar
    notifyListeners();
  }

  /// 🔐 LOGIN COM EMAIL E SENHA
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// 📝 CADASTRO COM EMAIL E SENHA
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// 🕵️ LOGIN ANÔNIMO
  Future<bool> loginAnonymously() async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.signInAnonymously();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }
}