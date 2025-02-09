import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_command/flutter_command.dart';

class ItemLibraryViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final ICategoryRepository categoryRepository;

  late final Command<void, List<ItemUIModel>> fetchLastAddedItemsCommand;
  late final Command<void, List<String>> fetchCategoriesCommand;
  late final Command<String, void> filterItemsCommand;
  late final Command<ItemUIModel, void> createItemCommand;
  late final Command<String, void> deleteItemCommand;
  late final Command<void, void> refreshLibraryCommand;

  List<ItemUIModel> get availableItems => fetchLastAddedItemsCommand.value;

  List<String> get categories => fetchCategoriesCommand.value;

  String searchQuery = "";
  String? selectedCategory;
  bool isSortingAscending = true;
  String sortOrder = 'Year';
  bool isScrollingDown = false;

  ItemLibraryViewModel({
    required this.categoryRepository,
    required this.repository,
  }) {
    fetchLastAddedItemsCommand = Command.createAsyncNoParam(
      () async => await repository.fetchAvailableItems(),
      initialValue: [],
    );

    fetchCategoriesCommand = Command.createAsyncNoParam(
      () async => await categoryRepository.fetchAllCategories(),
      initialValue: [],
    );

    filterItemsCommand = Command.createSync((query) {
      searchQuery = query;
    }, initialValue: null);

    createItemCommand = Command.createAsync(
      (item) async {
        await repository.createItem(item);
      },
      initialValue: null,
    );

    deleteItemCommand = Command.createAsync(
      (itemKey) async {
        await repository.deleteItem(itemKey);
      },
      initialValue: null,
    );

    refreshLibraryCommand = Command.createAsyncNoParam(() async {
      await repository.fetchAvailableItems();
    }, initialValue: null);
  }

  void selectCategory(String? category) {
    selectedCategory = selectedCategory == category ? null : category;
    filterItemsCommand.execute(selectedCategory ?? '');
  }

  void sortItems(String order) {
    if (sortOrder == order) {
      isSortingAscending = !isSortingAscending;
    } else {
      sortOrder = order;
      isSortingAscending = true;
    }
    fetchLastAddedItemsCommand.execute();
  }

  void setScrollDirection(bool isScrollingDown) {
    if (this.isScrollingDown != isScrollingDown) {
      this.isScrollingDown = isScrollingDown;
    }
  }
}
