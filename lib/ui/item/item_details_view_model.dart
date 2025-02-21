import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final IItemRepository repository;
  ItemUIModel item;
  String? errorMessage;
  late final Stream<ItemUIModel?> itemStream;

  ItemDetailViewModel({
    required this.repository,
    required ItemUIModel initialItem,
  }) : item = initialItem {
    _initializeStream();
  }

  void _initializeStream() {
    itemStream = repository.fetchItemStream(item.key);
    itemStream.listen((updatedItem) {
      if (updatedItem != null) {
        item = updatedItem;
        notifyListeners();
      }
    }, onError: (error) {
      errorMessage = "Failed to load item";
      notifyListeners();
    });
  }

  Future<void> deleteItem() async {
    try {
      await repository.deleteItem(item.key);
    } catch (e) {
      errorMessage = "Failed to delete item";
    }
    notifyListeners();
  }
}
