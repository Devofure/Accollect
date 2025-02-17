import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/firebase_service.dart';
import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();

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
    final router = AppRouterConfig.configureRouter(context);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Accollect',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
    );
  }
}
