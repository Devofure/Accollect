import 'package:flutter/foundation.dart';
import 'package:flutter_command/flutter_command.dart';

import '../../data/category_repository.dart';
import '../../data/item_repository.dart';
import '../../domain/models/item_ui_model.dart';

class ItemLibraryViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final ICategoryRepository categoryRepository;

  late final Stream<List<ItemUIModel>> itemsStream;
  late final Command<void, List<String>> fetchCategoriesCommand;
  late final Command<String, void> filterItemsCommand;
  late final Command<ItemUIModel, void> createItemCommand;
  late final Command<String, void> deleteItemCommand;

  String searchQuery = "";
  String? selectedCategory;
  bool isSortingAscending = true;
  bool isScrollingDown = false;
  List<ItemUIModel> availableItems = [];

  ItemLibraryViewModel({
    required this.categoryRepository,
    required this.repository,
  }) {
    itemsStream = repository.fetchItemsStream().map((allItems) {
      availableItems = allItems;
      return _filterAndSearch(allItems);
    });

    fetchCategoriesCommand = Command.createAsyncNoParam<List<String>>(
      categoryRepository.fetchAllCategories,
      initialValue: [],
    );
    fetchCategoriesCommand.execute();

    filterItemsCommand = Command.createSync(
      (query) {
        searchQuery = query;
        notifyListeners();
      },
      initialValue: null,
    );

    createItemCommand = Command.createAsync((item) async {
      await repository.createItem(item);
    }, initialValue: null);
  }

  void selectCategory(String? category) {
    selectedCategory = (selectedCategory == category) ? null : category;
    notifyListeners();
  }

  void setScrollDirection(bool scrollingDown) {
    if (isScrollingDown != scrollingDown) {
      isScrollingDown = scrollingDown;
      notifyListeners();
    }
  }

  /// Helper method to do local filtering + searching
  List<ItemUIModel> _filterAndSearch(List<ItemUIModel> items) {
    return items.where((item) {
      if (selectedCategory != null && item.category != selectedCategory) {
        return false;
      }
      if (searchQuery.isNotEmpty &&
          !item.title.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }
}
