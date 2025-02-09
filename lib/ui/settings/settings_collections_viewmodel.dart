import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_command/flutter_command.dart';

class CollectionManagementViewModel extends ChangeNotifier {
  final ICategoryRepository categoryRepository;
  final ICollectionRepository collectionRepository;
  final IItemRepository itemRepository;

  late Command<void, List<String>> fetchEditableCategoriesCommand;
  late Command<String, void> addCategoryCommand;
  late Command<String, void> deleteCategoryCommand;
  late Command<void, void> deleteAllCollectionsCommand;
  late Command<void, void> deleteAllDataCommand;

  CollectionManagementViewModel({
    required this.categoryRepository,
    required this.collectionRepository,
    required this.itemRepository,
  }) {
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
        await collectionRepository.deleteAllCollections();
      },
      initialValue: null,
    );

    deleteAllDataCommand = Command.createAsyncNoParam<void>(
      () async {
        await collectionRepository.deleteAllCollections();
        await itemRepository.deleteAllItems();
        await categoryRepository.deleteAllCategory();
      },
      initialValue: null,
    );

    fetchEditableCategoriesCommand.execute();
  }
}
