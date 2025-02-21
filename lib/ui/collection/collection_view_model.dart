import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class CollectionViewModel extends ChangeNotifier {
  final ICollectionRepository collectionRepository;
  final IItemRepository itemRepository;

  CollectionUIModel collection;
  String? errorMessage;
  late Stream<List<ItemUIModel>> itemsStream;

  CollectionViewModel({
    required this.collectionRepository,
    required this.itemRepository,
    required CollectionUIModel initialCollection,
  }) : collection = initialCollection {
    _initializeStreams();
    _fetchLatestCollection();
  }

  void _initializeStreams() {
    itemsStream = itemRepository
        .fetchItemsFromCollectionStream(collection.key)
        .handleError((error) {
      errorMessage = 'Failed to load items';
      debugPrint('Error loading items stream: $error');
      notifyListeners();
    });
  }

  Future<void> _fetchLatestCollection() async {
    try {
      final updatedCollection =
          await collectionRepository.fetchCollectionDetails(collection.key);
      collection = updatedCollection;
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load collection details';
      debugPrint('Error fetching collection: $e');
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await _fetchLatestCollection();
  }

  void removeItemFromCollection(String key) {
    itemRepository.removeItemFromCollection(collection.key, key);
  }
}
