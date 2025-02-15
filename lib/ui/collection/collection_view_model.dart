import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class CollectionViewModel extends ChangeNotifier {
  final ICollectionRepository collectionRepository;
  final IItemRepository itemRepository;
  final String collectionKey;

  String collectionName = '';
  String? collectionImageUrl;
  String? errorMessage;
  late Stream<List<ItemUIModel>> itemsStream;

  CollectionViewModel({
    required this.collectionKey,
    required this.collectionRepository,
    required this.itemRepository,
  }) {
    _initializeStreams();
    _loadCollectionDetails();
  }

  void _initializeStreams() {
    itemsStream = itemRepository
        .fetchItemsFromCollectionStream(collectionKey)
        .handleError((error) {
      errorMessage = 'Failed to load items';
      debugPrint('Error loading items stream: $error');
      notifyListeners();
    });
  }

  Future<void> _loadCollectionDetails() async {
    try {
      final collection =
          await collectionRepository.fetchCollectionDetails(collectionKey);
      collectionName = collection.name;
      collectionImageUrl = collection.imageUrl;
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load collection details';
      debugPrint('Error fetching collection: $e');
      notifyListeners();
    }
  }

  void removeItemFromCollection(String key) {
    itemRepository.removeItemFromCollection(collectionKey, key);
  }

  /// 🔄 **Refreshes the collection details & restarts the item stream.**
  Future<void> refreshData() async {
    debugPrint("🔄 Refreshing collection data...");
    await _loadCollectionDetails();
    _initializeStreams();
    notifyListeners();
  }
}
