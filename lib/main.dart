import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/ui/collection/collection_screen.dart';
import 'package:accollect/ui/collection/collection_view_model.dart';
import 'package:accollect/ui/collection/create_collection_screen.dart';
import 'package:accollect/ui/collection/create_collection_view_model.dart';
import 'package:accollect/ui/home/home_screen.dart';
import 'package:accollect/ui/home/home_view_model.dart';
import 'package:accollect/ui/item/add_or_select_item_screen.dart';
import 'package:accollect/ui/item/add_or_select_item_view_model.dart';
import 'package:accollect/ui/item/create_item_screen.dart';
import 'package:accollect/ui/item/create_item_view_model.dart';
import 'package:accollect/ui/item/item_details_screen.dart';
import 'package:accollect/ui/item/item_details_view_model.dart';
import 'package:accollect/ui/item/item_library_screen.dart';
import 'package:accollect/ui/item/item_library_view_model.dart';
import 'package:accollect/ui/onboarding/onboarding_screen.dart';
import 'package:accollect/ui/settings/settings_collection_management_screen.dart';
import 'package:accollect/ui/settings/settings_collection_management_view_model.dart';
import 'package:accollect/ui/settings/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider, EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final categoryRepository = CategoryRepository();
  final collectionRepository = CollectionRepository();
  final itemRepository = ItemRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<ICategoryRepository>.value(value: categoryRepository),
        Provider<ICollectionRepository>.value(value: collectionRepository),
        Provider<IItemRepository>.value(value: itemRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = _authProviders();
    final router = _configureRouter(context, providers);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Accollect',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
    );
  }

  List<AuthProvider<AuthListener, AuthCredential>> _authProviders() {
    return [
      EmailAuthProvider(),
      GoogleProvider(
        clientId:
            '256581349302-cu3676dq09s1ub8eg84pl3r9k4uottat.apps.googleusercontent.com',
      ),
    ];
  }

  GoRouter _configureRouter(
    BuildContext context,
    List<AuthProvider<AuthListener, AuthCredential>> providers,
  ) {
    return GoRouter(
      initialLocation: FirebaseAuth.instance.currentUser != null
          ? AppRouter.homeRoute
          : AppRouter.onboardingRoute,
      routes: [
        GoRoute(
          path: AppRouter.onboardingRoute,
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRouter.signupRoute,
          builder: (_, __) => SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                context.go(AppRouter.homeRoute);
              }),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return const _SignInHeader();
            },
          ),
        ),
        GoRoute(
          path: AppRouter.homeRoute,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (_) => HomeViewModel(
                collectionRepository: context.read(),
                itemRepository: context.read(),
              ),
              child: const HomeScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRouter.settingsRoute,
          builder: (_, __) => const SettingsScreen(),
        ),
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
            final collectionKey = state.pathParameters['key']!;
            return ChangeNotifierProvider(
              create: (context) => CollectionViewModel(
                collectionKey: collectionKey,
                collectionRepository: context.read<ICollectionRepository>(),
                itemRepository: context.read<IItemRepository>(),
              ),
              child: CollectionScreen(collectionKey: collectionKey),
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
          path: AppRouter.addNewItemRoute,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (_) => AddNewItemViewModel(
                categoryRepository: context.read<ICategoryRepository>(),
                itemRepository: context.read<IItemRepository>(),
              ),
              child: const CreateItemScreen(),
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
      ],
    );
  }
}

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
