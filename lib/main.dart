import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider, EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:go_router/go_router.dart';

// Core navigation
import 'core/navigation/app_router.dart';

// Features
import 'features/auth/signup_screen.dart';
import 'features/collection/add_new_item_screen.dart';
import 'features/collection/collection_model.dart';
import 'features/collection/collection_screen.dart';
import 'features/collection/create_collection_screen.dart';
import 'features/collection/item_details_screen.dart';
import 'features/collection/item_model.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configure authentication providers
    final providers = _authProviders();

    // Configure the app's routes
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
  // Helper: Authentication Providers
  // -------------------------------
  List<AuthProvider<AuthListener, AuthCredential>> _authProviders() {
    return [
      EmailAuthProvider(),
      GoogleProvider(
        clientId: '256581349302-cu3676dq09s1ub8eg84pl3r9k4uottat.apps.googleusercontent.com',
      ),
    ];
  }

  // -------------------------------
  // Helper: Configure Routes
  // -------------------------------
  GoRouter _configureRouter(List<AuthProvider<AuthListener, AuthCredential>> providers) {
    return GoRouter(
      routes: [
        // Onboarding
        GoRoute(
          path: AppRouter.onboardingRoute, // '/'
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

        // Signup
        GoRoute(
          path: AppRouter.signupRoute, // '/signup'
          builder: (_, __) => const SignupScreen(),
        ),

        // Home
        GoRoute(
          path: AppRouter.homeRoute, // '/home'
          builder: (_, __) => HomeScreen(
            userName: 'Alex Johnson',
            collections: _mockCollections(),
            latestItems: _mockItems(),
          ),
        ),

        // Create Collection
        GoRoute(
          path: AppRouter.createCollectionRoute, // '/create-collection'
          builder: (_, __) => const CreateCollectionScreen(),
        ),

        // Collection Details
        GoRoute(
          path: AppRouter.collectionRoute, // '/collection/:key'
          builder: (context, state) {
            final collectionKey = state.pathParameters['key'];
            return CollectionScreen(collectionKey: collectionKey!);
          },
        ),

        // Add New Item
        GoRoute(
          path: AppRouter.addNewItemRoute, // '/add-item'
          builder: (_, __) => const AddNewItemScreen(),
        ),

        // Item Details
        GoRoute(
          path: AppRouter.itemDetailsRoute, // '/item-details/:key'
          builder: (context, state) {
            final itemKey = state.pathParameters['key'];
            return ItemDetailsScreen(itemId: itemKey!);
          },
        ),
      ],
    );
  }

  // -------------------------------
  // Mock Data for Home Screen
  // -------------------------------
  List<CollectionModel> _mockCollections() {
    return [
      CollectionModel(
        key: '1',
        name: 'LEGO',
        description: 'Build your imagination',
        imageUrl: 'https://via.placeholder.com/50',
        itemCount: 12,
      ),
      CollectionModel(
        key: '2',
        name: 'My wines',
        description: 'Collection of exquisite wines',
        imageUrl: 'https://via.placeholder.com/50',
        itemCount: 23,
      ),
      CollectionModel(
        key: '3',
        name: 'Funko Pop',
        description: 'Collectible superhero figurine',
        imageUrl: 'https://via.placeholder.com/50',
        itemCount: 7,
      ),
    ];
  }

  List<ItemModel> _mockItems() {
    return [
      ItemModel(
        key: 'afasd',
        title: 'Super Guy',
        imageUrl: 'https://via.placeholder.com/40',
        addedOn: DateTime(2023, 10, 16),
      ),
      ItemModel(
        key: 'afasd1',
        title: 'Super Guy',
        imageUrl: 'https://via.placeholder.com/40',
        addedOn: DateTime(2023, 10, 10),
      ),
      ItemModel(
        key: 'afasd2',
        title: 'Super Guy',
        imageUrl: 'https://via.placeholder.com/40',
        addedOn: DateTime(2023, 10, 1),
      ),
    ];
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
