import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Registro anónimo (para mantener la app sin login pero con ID único)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print("Error en signInAnonymously: $e");
      return null;
    }
  }

  // Verificar si el usuario está autenticado y autenticar anónimamente si no lo está
  Future<User?> ensureUserAuthenticated() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        final credential = await signInAnonymously();
        user = credential?.user;
      }
      return user;
    } catch (e) {
      print("Error en ensureUserAuthenticated: $e");
      return null;
    }
  }
}
