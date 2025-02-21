import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final String itemKey;
  final IItemRepository repository;
  late final Stream<ItemUIModel?> itemStream;

  ItemDetailViewModel({required this.itemKey, required this.repository}) {
    itemStream = repository.fetchItemStream(itemKey);
  }

  Future<void> deleteItem() async {
    await repository.deleteItem(itemKey);
    notifyListeners();
  }
}