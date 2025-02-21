import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final ItemUIModel initialItem;
  String? _errorMessage;
  late final Stream<ItemUIModel?> itemStream;

  ItemDetailViewModel({
    required this.repository,
    required this.initialItem,
  }) {
    itemStream = _createItemStream();
  }

  Stream<ItemUIModel?> _createItemStream() {
    return Stream.value(initialItem)
        .asyncExpand((_) => repository.fetchItemStream(initialItem.key))
        .handleError((error) {
      _setError("Failed to load item", error);
    });
  }

  Future<void> deleteItem() async {
    try {
      await repository.deleteItem(initialItem.key);
    } catch (e) {
      _setError("Failed to delete item", e);
    }
  }

  void _setError(String message, Object error) {
    _errorMessage = message;
    debugPrint('$message: $error');
    notifyListeners();
  }

  String? get errorMessage => _errorMessage;
}
