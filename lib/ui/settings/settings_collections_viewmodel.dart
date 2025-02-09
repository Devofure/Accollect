import 'package:accollect/data/category_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_command/flutter_command.dart';

class CollectionManagementViewModel extends ChangeNotifier {
  final ICategoryRepository categoryRepository;

  late Command<void, List<String>> fetchEditableCategoriesCommand;
  late Command<String, void> addCategoryCommand;
  late Command<String, void> deleteCategoryCommand;
  late Command<void, void> deleteAllCollectionsCommand;
  late Command<void, void> deleteAllDataCommand;

  CollectionManagementViewModel({required this.categoryRepository}) {
    _setupCommands();
  }

  void _setupCommands() {
    fetchEditableCategoriesCommand = Command.createAsyncNoParam<List<String>>(
      categoryRepository.fetchEditableCategories,
      initialValue: [],
    );

    addCategoryCommand = Command.createAsync<String, void>(
      (category) async {
        await categoryRepository.addCategory(category);
        fetchEditableCategoriesCommand.execute();
      },
      initialValue: null,
    );

    deleteCategoryCommand = Command.createAsync<String, void>(
      (category) async {
        await categoryRepository.deleteCategory(category);
        fetchEditableCategoriesCommand.execute();
      },
      initialValue: null,
    );

    deleteAllCollectionsCommand = Command.createAsyncNoParam<void>(
      () async {
        // Implement delete all collections logic
      },
      initialValue: null,
    );

    deleteAllDataCommand = Command.createAsyncNoParam<void>(
      () async {
        // Implement delete all data logic
      },
      initialValue: null,
    );

    fetchEditableCategoriesCommand.execute();
  }
}
