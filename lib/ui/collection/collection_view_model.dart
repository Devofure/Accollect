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
  List<ItemUIModel> items = [];
  bool isLoading = true;
  String? errorMessage;

  CollectionViewModel({
    required this.collectionKey,
    required this.collectionRepository,
    required this.itemRepository,
  }) {
    _loadData();
  }

  Future<void> _loadData() async {
    debugPrint('Loading data for collection: $collectionKey');
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final collection =
          await collectionRepository.fetchCollectionDetails(collectionKey);
      collectionName = collection.name;
      collectionImageUrl = collection.imageUrl;

      debugPrint('Collection details loaded: $collectionName');
      items = await itemRepository.fetchItems(collectionKey);

      debugPrint('Items loaded: ${items.map((e) => e.title).toList()}');
      isLoading = false;
    } catch (e) {
      errorMessage = 'Failed to load collection data';
      debugPrint('Error while loading data: $e');
      isLoading = false;
    } finally {
      notifyListeners();
    }
  }

  void retryFetchingData() {
    debugPrint('Retrying data fetch...');
    _loadData();
  }

  Future<void> refreshData() async {
    debugPrint('Refreshing collection data...');
    await _loadData();
  }

  void removeItemFromCollection(String key, String? collectionKey) {
    debugPrint('Removing item $key from collection $collectionKey');
    collectionRepository.removeItemFromCollection(collectionKey!, key);
    items.removeWhere((element) => element.key == key);
    notifyListeners();
  }
}
