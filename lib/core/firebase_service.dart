import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider, EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

class FirebaseService {
  static bool isTestEnvironment = false;

  static User? get currentUser =>
      isTestEnvironment ? null : FirebaseAuth.instance.currentUser;

  static Future<void> initializeFirebase({bool testEnv = false}) async {
    isTestEnvironment = testEnv;
    if (!testEnv) {
      await Firebase.initializeApp();
    }
  }

  static List<AuthProvider<AuthListener, AuthCredential>> getAuthProviders() {
    return [
      EmailAuthProvider(),
      GoogleProvider(
        clientId:
            '256581349302-cu3676dq09s1ub8eg84pl3r9k4uottat.apps.googleusercontent.com',
      ),
    ];
  }
}
