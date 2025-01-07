import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider
    hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'core/navigation/app_router.dart';
import 'features/collection/collection_model.dart';
import 'features/collection/item_model.dart';
import 'features/collection/add_new_item_screen.dart';
import 'features/collection/collection_screen.dart';
import 'features/collection/create_collection_screen.dart';
import 'features/collection/item_details_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1) Set up Auth Providers list for SignInScreen
    final providers = <AuthProvider<AuthListener, AuthCredential>>[
      EmailAuthProvider(),
      GoogleProvider(clientId: '256581349302-cu3676dq09s1ub8eg84pl3r9k4uottat.apps.googleusercontent.com'),
    ];

    // 2) Build the GoRouter with your existing routes plus a '/login' route
    final GoRouter router = GoRouter(
      routes: [
        // Onboarding
        GoRoute(
          path: AppRouter.onboardingRoute, // '/'
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRouter.signupRoute,
          builder: (context, state) {
            return SignInScreen(
              providers: providers,
              // When the user signs in, go to '/home'
              actions: [
                AuthStateChangeAction<SignedIn>((context, state) {
                  context.go(AppRouter.homeRoute);
                }),
              ],
              // Optional customization: header/footer
              headerBuilder: (context, constraints, shrinkOffset) {
                return Column(
                  children: const [
                    SizedBox(height: 24),
                    Text(
                      'Accollect Sign In',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 24),
                  ],
                );
              },
            );
          },
        ),

        // Signup (You can keep or remove, depending on your flow)
        GoRoute(
          path: AppRouter.signupRoute, // '/signup'
          builder: (_, __) => const SignupScreen(),
        ),

        // Home
        GoRoute(
          path: AppRouter.homeRoute, // '/home'
          builder: (context, state) {
            final mockCollections = [
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

            final mockItems = [
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

            return HomeScreen(
              userName: 'Alex Johnson',
              collections: mockCollections,
              latestItems: mockItems,
            );
          },
        ),

        // Create Collection
        GoRoute(
          path: AppRouter.createCollectionRoute, // '/create-collection'
          builder: (_, __) => const CreateCollectionScreen(),
        ),

        // Collection Route (dynamic: '/collection/:key')
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

        // Item Details (dynamic: '/item-details/:key')
        GoRoute(
          path: AppRouter.itemDetailsRoute, // '/item-details/:key'
          builder: (context, state) {
            final itemKey = state.pathParameters['key'];
            return ItemDetailsScreen(itemId: itemKey!);
          },
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Accollect',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
    );
  }
}
