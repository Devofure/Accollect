import 'package:accollect/core/data/collection_repository.dart';
import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/models/collection_ui_model.dart';
import 'package:accollect/core/models/item_ui_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  final IItemRepository itemRepository;
  final ICollectionRepository collectionRepository;

  List<CollectionUIModel> collections = [];
  List<ItemUIModel> latestItems = [];
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

      // 🔄 Listen to Firestore collections stream
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

      // 🔄 Listen to Firestore latest items stream
      itemRepository.fetchLatestItemsStream().listen(
        (fetchedItems) {
          latestItems = fetchedItems;
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

  void _updateLoadingState() {
    // 🛑 Stop loading after both streams have fetched at least once
    if (_hasFetchedCollections && _hasFetchedItems) {
      isLoading = false;
    }
    notifyListeners();
  }

  void retryFetchingData() {
    _listenToData();
  }
}