import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Adjust imports as needed
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        // Onboarding
        GoRoute(
          path: AppRouter.onboardingRoute, // '/'
          builder: (_, __) => const OnboardingScreen(),
        ),

        // Signup
        GoRoute(
          path: AppRouter.signupRoute, // '/signup'
          builder: (_, __) => const SignupScreen(),
        ),

        // Home
        GoRoute(
          path: AppRouter.homeRoute, // '/home'
          builder: (context, state) {
            // ------------------------------------------
            // Example: Provide mock data to HomeScreen
            // Toggle collections below between [] or a populated list
            // ------------------------------------------
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
            // Grab the 'key' from pathParameters
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
    );
  }
}
