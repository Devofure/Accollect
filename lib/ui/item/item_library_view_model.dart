import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_command/flutter_command.dart';

class ItemLibraryViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final ICategoryRepository categoryRepository;

  late final Command<void, List<String>> fetchCategoriesCommand;
  late final Command<ItemUIModel, void> createItemCommand;
  late final Command<String?, void> selectCategoryCommand;
  late final Command<String?, void> searchQueryCommand;

  late final Stream<List<ItemUIModel>> itemsStream =
      repository.fetchItemsStream(categoryFilter);

  bool isScrollingDown = false;
  String? categoryFilter;

  ItemLibraryViewModel({
    required this.categoryRepository,
    required this.repository,
  }) {
    fetchCategoriesCommand = Command.createAsyncNoParam<List<String>>(
      categoryRepository.fetchAllCategories,
      initialValue: [],
    );
    fetchCategoriesCommand.execute();
    selectCategoryCommand = Command.createAsyncNoResult(
      (category) async {
        if (categoryFilter == category) {
          categoryFilter = null;
        } else {
          categoryFilter = category;
        }
        notifyListeners();
      },
    );

    createItemCommand = Command.createAsync(
      (item) async {
        await repository.createItem(item);
      },
      initialValue: null,
    );
  }

  void setScrollDirection(bool scrollingDown) {
    if (isScrollingDown != scrollingDown) {
      isScrollingDown = scrollingDown;
      notifyListeners();
    }
  }
}
