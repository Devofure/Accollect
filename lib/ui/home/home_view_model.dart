import 'package:accollect/core/firebase_service.dart';
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
  final IFirebaseService firebaseService;

  HomeViewModel({
    required this.itemRepository,
    required this.collectionRepository,
    required this.firebaseService,
  });

  User? get currentUser => firebaseService.currentUser;

  Stream<List<CollectionUIModel>> get collectionsStream =>
      collectionRepository.fetchCollectionsStream();

  Stream<Map<String, List<ItemUIModel>>> get latestItemsStream =>
      itemRepository.fetchLatestItemsStream().map(_groupItemsByDate);

  Map<String, List<ItemUIModel>> _groupItemsByDate(List<ItemUIModel> items) {
    final Map<String, List<ItemUIModel>> groupedItems = {};
    for (var item in items) {
      String dateKey = DateFormat('yyyy-MM-dd').format(item.addedOn);
      groupedItems.putIfAbsent(dateKey, () => []).add(item);
    }
    return groupedItems;
  }

  Stream<User?> get userChanges => firebaseService.userChanges;
}
