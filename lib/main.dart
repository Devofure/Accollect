import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/firebase_service.dart';
import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseService = FirebaseService();
  await firebaseService.initialize();

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
      child: MyApp(firebaseService: firebaseService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final IFirebaseService firebaseService;

  const MyApp({super.key, required this.firebaseService});

  @override
  Widget build(BuildContext context) {
    final router = AppRouterConfig.configureRouter(context, firebaseService);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Accollect',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
    );
  }
}
