// CollectionViewModel
import 'package:accollect/core/data/collection_repository.dart';
import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/models/item_ui_model.dart';
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
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final collection =
          await collectionRepository.fetchCollectionDetails(collectionKey);
      collectionName = collection.name;
      collectionImageUrl = collection.imageUrl;
      items = await itemRepository.fetchItems(collectionKey);

      isLoading = false;
    } catch (e) {
      errorMessage = 'Failed to load collection data';
      isLoading = false;
    } finally {
      notifyListeners();
    }
  }

  void retryFetchingData() {
    _loadData();
  }
}
