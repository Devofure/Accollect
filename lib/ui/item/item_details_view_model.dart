import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final String itemKey;
  final IItemRepository repository;
  late final Stream<ItemUIModel?> itemStream;

  ItemUIModel? item;
  bool isLoading = true;
  String? errorMessage;

  ItemDetailViewModel({required this.itemKey, required this.repository}) {
    itemStream = repository.fetchItemStream(itemKey);
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
