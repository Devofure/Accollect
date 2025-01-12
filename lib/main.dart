import 'package:accollect/core/models/item_ui_model.dart';
import 'package:accollect/features/collection/data/collection_repository.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider, EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/navigation/app_router.dart';
import 'features/collection/add_new_item_screen.dart';
import 'features/collection/collection_screen.dart';
import 'features/collection/create_collection_screen.dart';
import 'features/collection/item_details_screen.dart';
import 'features/home/data/home_repository.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = _authProviders();
    final router = _configureRouter(providers);
    return MaterialApp.router(
      routerConfig: router,
      title: 'Accollect',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
    );
  }

  // -------------------------------
  // Authentication Providers
  // -------------------------------
  List<AuthProvider<AuthListener, AuthCredential>> _authProviders() {
    return [
      EmailAuthProvider(),
      GoogleProvider(
        clientId:
            '256581349302-cu3676dq09s1ub8eg84pl3r9k4uottat.apps.googleusercontent.com',
      ),
    ];
  }

  // -------------------------------
  // Configure Routes
  // -------------------------------
  GoRouter _configureRouter(
      List<AuthProvider<AuthListener, AuthCredential>> providers) {
    return GoRouter(
      initialLocation: FirebaseAuth.instance.currentUser != null
          ? AppRouter.homeRoute // If already signed in, navigate to Home
          : AppRouter.onboardingRoute, // Otherwise, go to Onboarding
      routes: [
        // Onboarding
        GoRoute(
          path: AppRouter.onboardingRoute,
          builder: (_, __) => const OnboardingScreen(),
        ),

        // Login (Firebase UI)
        GoRoute(
          path: AppRouter.signupRoute,
          builder: (_, __) => SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                context.go(AppRouter.homeRoute); // Navigate to home on sign-in
              }),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return const _SignInHeader();
            },
          ),
        ),

        // Home
        GoRoute(
          path: AppRouter.homeRoute, // '/home'
          builder: (context, state) {
            return HomeScreen(repository: HomeRepository());
          },
        ),

        // Settings
        GoRoute(
          path: AppRouter.settingsRoute,
          builder: (_, __) => const SettingsScreen(),
        ),

        GoRoute(
          path: AppRouter.createCollectionRoute,
          builder: (_, __) => CreateCollectionScreen(),
        ),

        // Collection Details
        GoRoute(
          path: AppRouter.collectionRoute,
          builder: (context, state) {
            final collectionKey = state.pathParameters['key'];
            return CollectionScreen(
              collectionKey: collectionKey!,
              repository: CollectionRepository(),
            );
          },
        ),

        // Add New Item
        GoRoute(
          path: AppRouter.addNewItemRoute,
          builder: (_, __) => const AddNewItemScreen(),
        ),

        // Item Details
        GoRoute(
          path: AppRouter.itemDetailsRoute,
          builder: (context, state) {
            final itemKey = state.pathParameters['key'];

            return ItemDetailsScreen(
              itemId: itemKey!,
            );
          },
        ),
      ],
    );
  }

  List<ItemUIModel> _mockItems() {
    return [
      ItemUIModel(
        key: '1',
        title: 'Chateau Margaux',
        imageUrl: 'https://via.placeholder.com/80',
        addedOn: DateTime.now(),
        description: '',
      ),
    ];
  }

  // -------------------------------
  // Mock Data for Collection Screen
  // -------------------------------
  Map<String, Object> _getMockCollectionData(String? key) {
    if (key == '1') {
      return {
        'name': 'My Wines',
        'imageUrl': 'https://via.placeholder.com/150',
        'items': [
          {
            'title': 'Chateau Margaux',
            'year': '2015',
            'origin': 'France',
            'description': 'A rich and full-bodied wine.',
            'imageUrl': 'https://via.placeholder.com/80',
          },
          {
            'title': 'Riesling',
            'year': '2018',
            'origin': 'Germany',
            'description': 'A crisp and refreshing white wine.',
            'imageUrl': 'https://via.placeholder.com/80',
          },
        ],
      };
    } else if (key == '2') {
      return {
        'name': 'LEGO Collection',
        'imageUrl': 'https://via.placeholder.com/150',
        'items': [],
      };
    } else {
      return {
        'name': 'Unknown Collection',
        'imageUrl': '',
        'items': [],
      };
    }
  }
}

// -------------------------------
// Custom Sign-In Header Widget
// -------------------------------
class _SignInHeader extends StatelessWidget {
  const _SignInHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 24),
        Text(
          'Accollect Sign In',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 24),
      ],
    );
  }
}
