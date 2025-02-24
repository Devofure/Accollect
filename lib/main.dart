import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/app_themes.dart';
import 'package:accollect/core/firebase_service.dart';
import 'package:accollect/core/utils/theme_provider.dart';
import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/data/item_suggestions_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseService = FirebaseService();
  await firebaseService.initialize();
  Command.globalExceptionHandler = (command, exception) {
    debugPrint("Error in Command: ${command.commandName}: $exception");
  };

  runApp(
    MultiProvider(
      providers: [
        Provider<ICategoryRepository>.value(value: CategoryRepository()),
        Provider<ICollectionRepository>.value(value: CollectionRepository()),
        Provider<IItemRepository>.value(value: ItemRepository()),
        Provider<IItemSuggestionRepository>.value(
            value: ItemSuggestionRepository()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'Accollect',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
        );
      },
    );
  }
}
