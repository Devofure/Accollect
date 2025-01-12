class ItemModel {
  final String key;
  final String title;
  final String description;

  // Additional fields for wine, Funko Pop, LEGO, etc.

  ItemModel({
    required this.key,
    required this.title,
    required this.description,
    required imageUrl,
    required DateTime addedOn,
  });
}
