import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class CollectionViewModel extends ChangeNotifier {
  final ICollectionRepository collectionRepository;
  final IItemRepository itemRepository;

  CollectionUIModel collection;

  late final Stream<List<ItemUIModel>> _itemsStream;

  Stream<List<ItemUIModel>> get itemsStream => _itemsStream;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  CollectionViewModel({
    required this.collectionRepository,
    required this.itemRepository,
    required CollectionUIModel initialCollection,
  }) : collection = initialCollection {
    _itemsStream = _createItemsStream();
    _fetchLatestCollection();
  }

  Stream<List<ItemUIModel>> _createItemsStream() {
    return itemRepository
        .fetchItemsFromCollectionStream(collection.key)
        .handleError(
      (error, stackTrace) {
        _setError("Failed to load items", error, stackTrace);
      },
    );
  }

  Future<void> _fetchLatestCollection() async {
    try {
      final updatedCollection =
          await collectionRepository.fetchCollectionDetails(collection.key);
      collection = updatedCollection;
      _errorMessage = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _setError("Failed to load collection details", e, stackTrace);
    }
  }

  Future<void> refreshData() async {
    await _fetchLatestCollection();
  }

  void removeItemFromCollection(String key) {
    itemRepository.removeItemFromCollection(collection.key, key);
  }

  void _setError(String message, Object error, StackTrace stackTrace) {
    _errorMessage = message;
    debugPrint('$message: $error\n$stackTrace');
    notifyListeners();
  }
}
