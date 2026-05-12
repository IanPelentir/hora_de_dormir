import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Necessário para salvar o aceite
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  bool _acceptedTerms = false; // ✅ Novo estado para LGPD

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  User? get user => _user;
  bool get acceptedTerms => _acceptedTerms; // ✅ Getter para a SplashView consultar

  AuthProvider() {
    initAuth();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// 🔐 Inicialização e Persistência de Sessão
  Future<void> initAuth() async {
    _setError(null);

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _user = user;
      
      if (user != null) {
        // ✅ Sempre que o usuário logar, verificamos se ele já aceitou a LGPD no banco
        await _checkTermsStatus(user.uid);
      } else {
        _acceptedTerms = false;
      }
      
      notifyListeners();
    });
  }

  /// 🛡️ Verifica no Firestore se o usuário já aceitou os termos
  Future<void> _checkTermsStatus(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _acceptedTerms = doc.data()?['acceptedLGPD'] ?? false;
      } else {
        _acceptedTerms = false;
      }
    } catch (e) {
      debugPrint("Erro ao verificar LGPD: $e");
      _acceptedTerms = false;
    }
  }

  /// ✅ Salva o aceite dos termos (Chamado pela TermsView)
  Future<void> acceptTerms() async {
    if (_user == null) return;

    try {
      _setLoading(true);
      await _db.collection('users').doc(_user!.uid).set({
        'acceptedLGPD': true,
        'acceptedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      _acceptedTerms = true;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError("Erro ao salvar consentimento: $e");
      _setLoading(false);
    }
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
      _acceptedTerms = false;
    } catch (e) {
      _setError(_formatError(e));
    }
    _setLoading(false);
  }

  String _formatError(Object e) {
    return e.toString().replaceAll('Exception: ', '');
  }
}