import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider, EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'
    show FirebaseCrashlytics;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart' show FlutterError;

abstract class IFirebaseService {
  User? get currentUser;

  Future<void> initialize();

  List<AuthProvider<AuthListener, AuthCredential>> getAuthProviders();
}

class FirebaseService implements IFirebaseService {
  @override
  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  initialize() async {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  @override
  List<AuthProvider<AuthListener, AuthCredential>> getAuthProviders() => [
        EmailAuthProvider(),
        GoogleProvider(
          clientId:
              '256581349302-cu3676dq09s1ub8eg84pl3r9k4uottat.apps.googleusercontent.com',
        ),
      ];
}
