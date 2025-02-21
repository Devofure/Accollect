import 'package:accollect/core/firebase_service.dart';
import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/ui/auth/sign_in_header.dart';
import 'package:accollect/ui/collection/collection_screen.dart';
import 'package:accollect/ui/collection/collection_view_model.dart';
import 'package:accollect/ui/create/collection/create_collection_screen.dart';
import 'package:accollect/ui/create/collection/create_collection_view_model.dart';
import 'package:accollect/ui/create/item/multi_step_create_item_screen.dart';
import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:accollect/ui/home/home_screen.dart';
import 'package:accollect/ui/home/home_view_model.dart';
import 'package:accollect/ui/item/add_or_select_item_screen.dart';
import 'package:accollect/ui/item/add_or_select_item_view_model.dart';
import 'package:accollect/ui/item/item_details_screen.dart';
import 'package:accollect/ui/item/item_details_view_model.dart';
import 'package:accollect/ui/item/item_library_screen.dart';
import 'package:accollect/ui/item/item_library_view_model.dart';
import 'package:accollect/ui/onboarding/onboarding_screen.dart';
import 'package:accollect/ui/settings/settings_collection_management_screen.dart';
import 'package:accollect/ui/settings/settings_collection_management_view_model.dart';
import 'package:accollect/ui/settings/settings_screen.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRouterConfig {
  static GoRouter configureRouter(
    BuildContext context,
    IFirebaseService firebaseService,
  ) {
    final providers = firebaseService.getAuthProviders();

    return GoRouter(
      initialLocation: firebaseService.currentUser != null
          ? AppRouter.homeRoute
          : AppRouter.onboardingRoute,
      routes: [
        GoRoute(
            path: AppRouter.onboardingRoute,
            builder: (_, __) => const OnboardingScreen()),
        GoRoute(
          path: AppRouter.signupRoute,
          builder: (_, __) => SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                context.go(AppRouter.homeRoute);
              }),
            ],
            headerBuilder: (_, __, ___) => const SignInHeader(),
          ),
        ),
        GoRoute(
          path: AppRouter.homeRoute,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (_) => HomeViewModel(
                collectionRepository: context.read(),
                itemRepository: context.read(),
                firebaseService: firebaseService,
              ),
              child: const HomeScreen(),
            );
          },
        ),
        GoRoute(
            path: AppRouter.settingsRoute,
            builder: (_, __) => const SettingsScreen()),
        GoRoute(
          path: AppRouter.settingsCollectionsRoute,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (_) => CollectionManagementViewModel(
                categoryRepository: context.read<ICategoryRepository>(),
                collectionRepository: context.read<ICollectionRepository>(),
                itemRepository: context.read<IItemRepository>(),
              ),
              child: const CollectionManagementScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRouter.createCollectionRoute,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (_) => CreateCollectionViewModel(
                collectionRepository: context.read<ICollectionRepository>(),
                categoryRepository: context.read<ICategoryRepository>(),
              ),
              child: const CreateCollectionScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRouter.collectionRoute,
          builder: (context, state) {
            final collection = state.extra as CollectionUIModel;
            return ChangeNotifierProvider(
              create: (context) => CollectionViewModel(
                initialCollection: collection,
                collectionRepository: context.read<ICollectionRepository>(),
                itemRepository: context.read<IItemRepository>(),
              ),
              child: const CollectionScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRouter.itemLibraryRoute,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (_) => ItemLibraryViewModel(
                itemRepository: context.read<IItemRepository>(),
                categoryRepository: context.read<ICategoryRepository>(),
              ),
              child: const ItemLibraryScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRouter.createNewItemRoute,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (_) => MultiStepCreateItemViewModel(
                categoryRepository: context.read<ICategoryRepository>(),
                itemRepository: context.read<IItemRepository>(),
              ),
              child: const MultiStepCreateItemScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRouter.itemDetailsRoute,
          builder: (context, state) {
            final itemKey = state.pathParameters['key'];
            if (itemKey == null) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Text(
                    'Invalid item key',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            return ChangeNotifierProvider(
              create: (_) => ItemDetailViewModel(
                itemKey: itemKey,
                repository: context.read<IItemRepository>(),
              ),
              child: const ItemDetailScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRouter.addOrSelectItemRoute,
          builder: (context, state) {
            final collectionKey = state.pathParameters['key'];
            final collectionName = state.pathParameters['name'];
            final itemRepo = context.read<IItemRepository>();

            return ChangeNotifierProvider(
              create: (_) => AddOrSelectItemViewModel(
                repository: itemRepo,
                collectionKey: collectionKey,
              ),
              child: AddOrSelectItemScreen(
                collectionKey: collectionKey,
                collectionName: collectionName,
              ),
            );
          },
        ),
      ],
    );
  }
}

class AppRouter {
  static const String onboardingRoute = '/';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String settingsRoute = '/settings';
  static const String settingsCollectionsRoute = '/settings/collections';
  static const String createCollectionRoute = '/create-collection';
  static const String addOrSelectItemRoute = '/add-or-select-item/:key/:name';
  static const String itemLibraryRoute = '/item-library';
  static const String createNewItemRoute = '/add-new-item';
  static const String collectionRoute = '/collection';
  static const String itemDetailsRoute = '/item-details/:key';
}
