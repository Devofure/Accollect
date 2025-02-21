import 'package:accollect/core/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider, EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class MockFirebaseService implements IFirebaseService {
  User? _mockUser;

  @override
  User? get currentUser => _mockUser;

  @override
  Future<void> initialize() async {
    // Simulate delay for initialization if needed
    await Future.delayed(Duration(milliseconds: 100));
  }

  @override
  List<AuthProvider<AuthListener, AuthCredential>> getAuthProviders() {
    return [EmailAuthProvider()];
  }

  void setMockUser(User? user) {
    _mockUser = user;
  }

  @override
  Stream<User?> get userChanges => throw UnimplementedError();
}
