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

  /// 🔐 Inicialização de auth (útil para splash)
  Future<void> initAuth() async {
    _setError(null);

    try {
      // Apenas força leitura do estado atual do FirebaseAuth
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _setError("Erro ao inicializar autenticação");
    }

    notifyListeners();
  }

  /// 🔐 LOGIN
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_formatError(e));
      _setLoading(false);
      return false;
    }
  }

  /// 📝 REGISTRO
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.createUserWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_formatError(e));
      _setLoading(false);
      return false;
    }
  }

  /// 🕵️ ANÔNIMO
  Future<bool> loginAnonymously() async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signInAnonymously();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_formatError(e));
      _setLoading(false);
      return false;
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.signOut();
    } catch (e) {
      _setError(_formatError(e));
    }

    _setLoading(false);
    notifyListeners();
  }

  /// 🧠 helper de erro limpo
  String _formatError(Object e) {
    return e.toString().replaceAll('Exception: ', '');
  }
}