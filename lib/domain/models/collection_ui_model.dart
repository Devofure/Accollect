class CollectionUIModel {
  final String key;
  final String name;
  final String? description;
  final int itemCount;
  final String? imageUrl;
  final DateTime lastUpdated;
  final String? category;
  final bool isFavorite;
  final String visibility; // "public" or "private"

  CollectionUIModel({
    required this.key,
    required this.name,
    required this.description,
    required this.itemCount,
    this.imageUrl,
    required this.lastUpdated,
    required this.category,
    this.isFavorite = false,
    this.visibility = "private",
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'description': description,
      'itemCount': itemCount,
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated.toIso8601String(),
      'category': category,
      'isFavorite': isFavorite,
      'visibility': visibility,
    };
  }

  factory CollectionUIModel.fromJson(Map<String, dynamic> json) {
    return CollectionUIModel(
      key: json['key'],
      name: json['name'],
      description: json['description'],
      itemCount: json['itemCount'],
      imageUrl: json['imageUrl'],
      lastUpdated: DateTime.parse(
          json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? "Other",
      isFavorite: json['isFavorite'] ?? false,
      visibility: json['visibility'] ?? "private",
    );
  }
}
