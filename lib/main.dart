import 'package:accollect/features/collection/collection_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/navigation/app_router.dart';
import 'features/collection/item_model.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/home/home_screen.dart';
import 'features/collection/create_collection_screen.dart';
import 'features/collection/collection_screen.dart';
import 'features/collection/add_new_item_screen.dart';
import 'features/collection/item_details_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: AppRouter.onboardingRoute,
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRouter.signupRoute,
          builder: (_, __) => const SignupScreen(),
        ),
        GoRoute(
          path: AppRouter.homeRoute,
          builder: (context, state) {
            // ------------------------------------------
            // Example: Provide mock data to HomeScreen
            // Toggle collections below between an empty list ([])
            // and a populated list to see both states.
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
                title: 'Super Guy',
                imageUrl: 'https://via.placeholder.com/40',
                addedOn: DateTime(2023, 10, 16),
                key: 'afasd',
              ),
              ItemModel(
                title: 'Super Guy',
                imageUrl: 'https://via.placeholder.com/40',
                addedOn: DateTime(2023, 10, 10),
                key: 'afasd1',
              ),
              ItemModel(
                title: 'Super Guy',
                imageUrl: 'https://via.placeholder.com/40',
                addedOn: DateTime(2023, 10, 1),
                key: 'afasd2',
              ),
            ];

            return HomeScreen(
              userName: 'Alex Johnson',
              collections: mockCollections,
              latestItems: mockItems,
            );
          },
        ),
        GoRoute(
          path: AppRouter.createCollectionRoute,
          builder: (_, __) => const CreateCollectionScreen(),
        ),
        GoRoute(
          path: AppRouter.collectionRoute,
          builder: (context, state) {
            final itemKey = state.pathParameters['key'];
            return CollectionScreen(collectionKey:itemKey!);
          },
        ),
        GoRoute(
          path: AppRouter.addNewItemRoute,
          builder: (_, __) => const AddNewItemScreen(),
        ),
        GoRoute(
          // Example: /item-details/:id
          path: AppRouter.itemDetailsRoute,
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
