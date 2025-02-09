import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final String itemKey;
  final IItemRepository repository = ItemRepository(); // Inject repository

  ItemUIModel? item;
  bool isLoading = true;
  String? errorMessage;

  ItemDetailViewModel({required this.itemKey}) {
    fetchItem();
  }

  Future<void> fetchItem() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      item = await repository.getItemByKey(itemKey);
    } catch (e) {
      errorMessage = 'Item not found';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem() async {
    if (item == null) return;
    try {
      isLoading = true;
      notifyListeners();

      await repository.deleteItem(item!.key);
      item = null;
    } catch (e) {
      errorMessage = 'Failed to delete item';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
