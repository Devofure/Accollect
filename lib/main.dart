import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/ui/collection/collection_screen.dart';
import 'package:accollect/ui/collection/create_collection_screen.dart';
import 'package:accollect/ui/home/home_screen.dart';
import 'package:accollect/ui/home/home_view_model.dart';
import 'package:accollect/ui/item/add_new_item_screen.dart';
import 'package:accollect/ui/item/add_or_select_item_screen.dart';
import 'package:accollect/ui/item/item_details_screen.dart';
import 'package:accollect/ui/item/item_library_screen.dart';
import 'package:accollect/ui/onboarding/onboarding_screen.dart';
import 'package:accollect/ui/settings/settings_collections_screen.dart';
import 'package:accollect/ui/settings/settings_collections_viewmodel.dart';
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
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            collectionRepository: collectionRepository,
            itemRepository: itemRepository,
          ),
        ),
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
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRouter.settingsRoute,
          builder: (_, __) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRouter.settingsCollectionsRoute,
          builder: (context, state) {
            final categoryRepo = context.read<ICategoryRepository>();
            final collectionRepo = context.read<ICollectionRepository>();
            return ChangeNotifierProvider(
              create: (_) => CollectionManagementViewModel(
                categoryRepository: categoryRepo,
                collectionRepository: collectionRepo,
              ),
              child: const CollectionManagementScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRouter.createCollectionRoute,
          builder: (context, state) {
            final collectionRepo = context.read<ICollectionRepository>();
            final categoryRepo = context.read<ICategoryRepository>();
            return CreateCollectionScreen(
              collectionRepository: collectionRepo,
              categoryRepository: categoryRepo,
            );
          },
        ),
        GoRoute(
          path: AppRouter.collectionRoute,
          builder: (context, state) {
            final collectionKey = state.pathParameters['key'];
            final collectionRepo = context.read<ICollectionRepository>();
            final itemRepo = context.read<IItemRepository>();

            return CollectionScreen(
              collectionKey: collectionKey!,
              collectionRepository: collectionRepo,
              itemRepository: itemRepo,
            );
          },
        ),
        GoRoute(
          path: AppRouter.addOrSelectItemRoute,
          builder: (context, state) {
            final collectionKey = state.pathParameters['key'];
            final collectionName = state.pathParameters['name'];
            final itemRepo = context.read<IItemRepository>();

            return AddOrSelectItemScreen(
              collectionName: collectionName!,
              collectionKey: collectionKey!,
              repository: itemRepo,
            );
          },
        ),
        GoRoute(
          path: AppRouter.addNewItemRoute,
          builder: (context, state) => AddNewItemScreen(
            onCreateItem: (item) => context.pop(item),
          ),
        ),
        GoRoute(
          path: AppRouter.itemLibraryRoute,
          builder: (context, state) {
            final itemRepo = context.read<IItemRepository>();
            final categoryRepo = context.read<ICategoryRepository>();

            return ItemLibraryScreen(
              itemRepository: itemRepo,
              categoryRepository: categoryRepo,
            );
          },
        ),
        GoRoute(
          path: AppRouter.itemDetailsRoute,
          builder: (context, state) {
            final itemKey = state.pathParameters['key'];
            return ItemDetailScreen(itemKey: itemKey!);
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
