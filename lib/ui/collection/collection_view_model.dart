import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_command/flutter_command.dart';

class CollectionViewModel extends ChangeNotifier {
  final ICollectionRepository collectionRepository;
  final IItemRepository itemRepository;

  CollectionUIModel collection;

  late final Stream<List<ItemUIModel>> _itemsStream;

  Stream<List<ItemUIModel>> get itemsStream => _itemsStream;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;
  late Command<void, void> editCollectionCommand;
  late Command<void, void> deleteCollectionCommand;

  CollectionViewModel({
    required this.collectionRepository,
    required this.itemRepository,
    required CollectionUIModel initialCollection,
  }) : collection = initialCollection {
    _itemsStream = _createItemsStream();
    _fetchLatestCollection();
    _setupCommands();
  }

  void _setupCommands() {
    editCollectionCommand = Command.createAsyncNoParam<void>(() async {
      debugPrint('Editing collection: ${collection.key}');
    }, initialValue: null);

    deleteCollectionCommand = Command.createAsyncNoParam<void>(() async {
      debugPrint('Deleting collection: ${collection.key}');
      await collectionRepository.deleteCollection(collection.key);
    }, initialValue: null);
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

  placeholderAsset(String? category) {
    switch (category) {
      case 'Lego':
        return 'assets/images/category_lego.png';
      case "Funko Pop!":
        return 'assets/images/category_funko_pop.png';
      case "Hot Wheels":
        return 'assets/images/category_hot_wheels.png';
      case "Wine":
        return 'assets/images/category_wine.png';
      default:
        return 'assets/images/category_other.png';
    }
  }
}
