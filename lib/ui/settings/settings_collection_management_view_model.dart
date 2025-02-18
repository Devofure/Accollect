import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';

class CollectionManagementViewModel extends ChangeNotifier {
  final ICategoryRepository categoryRepository;
  final ICollectionRepository collectionRepository;
  final IItemRepository itemRepository;

  late Command<String, void> addCategoryCommand;
  late Command<String, void> deleteCategoriesCommand;
  late Command<void, void> deleteAllCollectionsCommand;
  late Command<void, void> deleteAllCategoriesCommand;
  late Command<void, void> deleteAllItemsCommand;
  late Command<void, void> deleteAllDataCommand;

  Stream<List<String>> get editableCategoriesStream =>
      categoryRepository.fetchUserCategoriesStream();

  CollectionManagementViewModel({
    required this.categoryRepository,
    required this.collectionRepository,
    required this.itemRepository,
  }) {
    _setupCommands();
  }

  void _setupCommands() {
    addCategoryCommand = Command.createAsync<String, void>(
      (category) async {
        await categoryRepository.addCategory(category);
      },
      initialValue: null,
    );

    deleteCategoriesCommand = Command.createAsync<String, void>(
      (category) async {
        await categoryRepository.deleteCategory(category);
      },
      initialValue: null,
    );

    deleteAllCollectionsCommand = Command.createAsyncNoParam<void>(
      () async {
        await collectionRepository.deleteAllCollections();
      },
      initialValue: null,
    );

    deleteAllCategoriesCommand = Command.createAsyncNoParam<void>(
      () async {
        await categoryRepository.deleteAllCategories();
      },
      initialValue: null,
    );

    deleteAllItemsCommand = Command.createAsyncNoParam<void>(
      () async {
        await itemRepository.deleteAllItems();
      },
      initialValue: null,
    );

    deleteAllDataCommand = Command.createAsyncNoParam<void>(
      () async {
        await collectionRepository.deleteAllCollections();
        await itemRepository.deleteAllItems();
        await categoryRepository.deleteAllCategories();
      },
      initialValue: null,
    );
  }
}
