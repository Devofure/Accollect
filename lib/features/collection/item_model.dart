// lib/features/home/item_model.dart

class ItemModel {
  final String key;
  final String title;
  final String imageUrl;
  final DateTime addedOn;

  ItemModel({
    required this.key,
    required this.title,
    required this.imageUrl,
    required this.addedOn,
  });
}
