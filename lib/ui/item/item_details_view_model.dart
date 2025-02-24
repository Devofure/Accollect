import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final ItemUIModel initialItem;

  late final Stream<ItemUIModel?> _itemStream;

  Stream<ItemUIModel?> get itemStream => _itemStream;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  String? favoriteImageUrl;

  ItemDetailViewModel({
    required this.repository,
    required this.initialItem,
  }) {
    favoriteImageUrl = initialItem.favoriteImageUrl;
    _itemStream = _createItemStream();
  }

  Stream<ItemUIModel?> _createItemStream() {
    return Stream.value(initialItem).asyncExpand(
      (_) => repository.fetchItemStream(initialItem.key).map((item) {
        if (item != null && favoriteImageUrl != item.favoriteImageUrl) {
          favoriteImageUrl = item.favoriteImageUrl;
          notifyListeners();
        }
        return item;
      }).handleError(
        (error, stackTrace) {
          _setError("Failed to load item", error, stackTrace);
        },
      ),
    );
  }

  Future<void> updateFavoriteImage(String itemKey, String imageUrl) async {
    await repository.updateFavoriteImage(itemKey, imageUrl);
    favoriteImageUrl = imageUrl;
    notifyListeners();
  }

  Future<void> deleteItem() async {
    try {
      await repository.deleteItem(initialItem.key);
    } catch (e, stackTrace) {
      _setError("Failed to delete item", e, stackTrace);
    }
  }

  void _setError(String message, Object error, StackTrace stackTrace) {
    _errorMessage = message;
    debugPrint('$message: $error\n$stackTrace');
    notifyListeners();
  }
}
