import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class HomeViewModel extends ChangeNotifier {
  final IItemRepository itemRepository;
  final ICollectionRepository collectionRepository;

  List<CollectionUIModel> collections = [];
  Map<String, List<ItemUIModel>> groupedLatestItems = {};
  bool isLoading = true;
  String? errorMessage;

  bool _hasFetchedCollections = false;
  bool _hasFetchedItems = false;

  HomeViewModel({
    required this.itemRepository,
    required this.collectionRepository,
  }) {
    _listenToData();
  }

  User? get currentUser => FirebaseAuth.instance.currentUser;

  void _listenToData() {
    try {
      isLoading = true;
      notifyListeners();

      collectionRepository.fetchCollectionsStream().listen(
        (fetchedCollections) {
          collections = fetchedCollections;
          _hasFetchedCollections = true;
          _updateLoadingState();
        },
        onError: (e) {
          errorMessage = 'Failed to load collections: $e';
          _hasFetchedCollections = true;
          _updateLoadingState();
        },
      );

      itemRepository.fetchLatestItemsStream().listen(
        (fetchedItems) {
          _processLatestItems(fetchedItems);
          _hasFetchedItems = true;
          _updateLoadingState();
        },
        onError: (e) {
          errorMessage = 'Failed to load latest items: $e';
          _hasFetchedItems = true;
          _updateLoadingState();
        },
      );
    } catch (e) {
      errorMessage = 'Unexpected error: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  void _processLatestItems(List<ItemUIModel> items) {
    final latestLimitedItems = items.take(10).toList(); // Only last 5 items
    groupedLatestItems = _groupItemsByDate(latestLimitedItems);
    notifyListeners();
  }

  Map<String, List<ItemUIModel>> _groupItemsByDate(List<ItemUIModel> items) {
    final Map<String, List<ItemUIModel>> groupedItems = {};
    for (var item in items) {
      String dateKey = DateFormat('yyyy-MM-dd').format(item.addedOn);
      if (!groupedItems.containsKey(dateKey)) {
        groupedItems[dateKey] = [];
      }
      groupedItems[dateKey]!.add(item);
    }
    return groupedItems;
  }

  void _updateLoadingState() {
    if (_hasFetchedCollections && _hasFetchedItems) {
      isLoading = false;
    }
    notifyListeners();
  }

  void retryFetchingData() {
    _listenToData();
  }
}
