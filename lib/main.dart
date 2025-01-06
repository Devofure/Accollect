import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/navigation/app_router.dart';
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
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRouter.createCollectionRoute,
          builder: (_, __) => const CreateCollectionScreen(),
        ),
        GoRoute(
          path: AppRouter.collectionRoute,
          builder: (_, __) => const CollectionScreen(),
        ),
        GoRoute(
          path: AppRouter.addNewItemRoute,
          builder: (_, __) => const AddNewItemScreen(),
        ),
        GoRoute(
          path: AppRouter.itemDetailsRoute,
          builder: (context, state) {
            final itemId = state.pathParameters['id'];
            return ItemDetailsScreen(id: itemId!);
          },
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Accollect',
      // Optionally customize theme, locale, etc.
    );
  }
}
