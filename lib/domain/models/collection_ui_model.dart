class CollectionUIModel {
  final String key;
  final String name;
  final String? description;
  final int? itemsCount;
  final String? imageUrl;
  final DateTime lastUpdated;
  final String? category;
  final bool? isFavorite;
  final String? visibility;

  CollectionUIModel({
    required this.key,
    required this.name,
    required this.description,
    required this.itemsCount,
    this.imageUrl,
    required this.lastUpdated,
    required this.category,
    this.isFavorite = false,
    this.visibility = "private",
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'itemsCount': itemsCount,
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated.toIso8601String(),
      'category': category,
      'isFavorite': isFavorite,
      'visibility': visibility,
    };
  }

  factory CollectionUIModel.fromJson(Map<String, dynamic> json, String key) {
    return CollectionUIModel(
      key: key,
      name: json['name'] ?? "Untitled",
      description: json['description'],
      itemsCount: json['itemsCount'] ?? 0,
      imageUrl: json['imageUrl'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      category: json['category'] ?? "Other",
      isFavorite: json['isFavorite'] ?? false,
      visibility: json['visibility'] ?? "private",
    );
  }
}
