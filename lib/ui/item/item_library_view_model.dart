import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_command/flutter_command.dart';

class ItemLibraryViewModel extends ChangeNotifier {
  final IItemRepository itemRepository;
  final ICategoryRepository categoryRepository;

  late final Command<void, List<String>> fetchCategoriesCommand;
  late final Command<ItemUIModel, void> createItemCommand;
  late final Command<String?, void> selectCategoryCommand;

  bool isScrollingDown = false;
  String? _categoryFilter;

  String? get categoryFilter => _categoryFilter;
  late Stream<List<ItemUIModel>> _itemsStream;

  Stream<List<ItemUIModel>> get itemsStream => _itemsStream;

  ItemLibraryViewModel({
    required this.categoryRepository,
    required this.itemRepository,
  }) {
    fetchCategoriesCommand = Command.createAsyncNoParam<List<String>>(
      categoryRepository.fetchAllCategories,
      initialValue: [],
    );
    fetchCategoriesCommand.execute();

    selectCategoryCommand = Command.createSyncNoResult<String?>((category) {
      _categoryFilter = (category == "All Items") ? null : category;
      _itemsStream = itemRepository.fetchItemsStream(_categoryFilter);
      notifyListeners();
    });

    createItemCommand = Command.createAsync(
      (item) async {
        await itemRepository.createItem(item);
      },
      initialValue: null,
    );

    _itemsStream = itemRepository.fetchItemsStream(_categoryFilter);
  }

  void setScrollDirection(bool scrollingDown) {
    if (isScrollingDown != scrollingDown) {
      isScrollingDown = scrollingDown;
      notifyListeners();
    }
  }
}
