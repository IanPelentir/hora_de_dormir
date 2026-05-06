import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retorna o usuário atual logado
  User? get currentUser => _auth.currentUser;

  /// Stream para ouvir mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login com E-mail e Senha
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Ocorreu um erro desconhecido durante o login.');
    }
  }

  /// Cadastro com E-mail e Senha
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Ocorreu um erro desconhecido durante o cadastro.');
    }
  }

  /// Login Anônimo
  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Ocorreu um erro desconhecido no login anônimo.');
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Tratamento de erros comuns do Firebase Auth
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Nenhum usuário encontrado com este e-mail.');
      case 'wrong-password':
        return Exception('Senha incorreta.');
      case 'invalid-email':
        return Exception('O formato do e-mail é inválido.');
      case 'user-disabled':
        return Exception('Este usuário foi desabilitado.');
      case 'email-already-in-use':
        return Exception('O e-mail já está em uso por outra conta.');
      case 'weak-password':
        return Exception('A senha fornecida é muito fraca.');
      case 'operation-not-allowed':
        return Exception('Operação não permitida. Contate o suporte.');
      case 'invalid-credential':
        return Exception('Credenciais inválidas ou incorretas.');
      default:
        return Exception(e.message ?? 'Erro de autenticação desconhecido.');
    }
  }
}
