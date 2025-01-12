import '../../../core/models/collection_ui_model.dart';
import '../../../core/models/item_ui_model.dart';

abstract class ICollectionRepository {
  /// Fetch collection details like name and image URL.
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey);

  /// Fetch the items within the collection.
  Future<List<ItemUIModel>> fetchItems(String collectionKey);
}

class CollectionRepository implements ICollectionRepository {
  @override
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey) async {
    // Mocked collection details
    return Future.delayed(
      const Duration(seconds: 1),
      () => CollectionUIModel(
        key: collectionKey,
        name: 'My Wines',
        description: 'A fine collection of wines.',
        imageUrl: 'https://via.placeholder.com/150',
        // Placeholder image URL
        itemCount: 5,
      ),
    );
  }

  @override
  Future<List<ItemUIModel>> fetchItems(String collectionKey) async {
    // Mocked items for the collection
    return Future.delayed(
      const Duration(seconds: 1),
      () => [
        ItemUIModel(
          key: 'item1',
          title: 'Chateau Margaux',
          imageUrl: 'https://via.placeholder.com/150',
          addedOn: DateTime.now(),
          description: 'A French wine from Bordeaux.',
        ),
        ItemUIModel(
          key: 'item2',
          title: 'Penfolds Grange',
          imageUrl: 'https://via.placeholder.com/150',
          addedOn: DateTime.now().subtract(const Duration(days: 1)),
          description: 'An Australian Shiraz.',
        ),
      ],
    );
  }
}
