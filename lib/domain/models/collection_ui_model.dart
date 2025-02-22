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
    this.description,
    this.itemsCount,
    this.imageUrl,
    required this.lastUpdated,
    this.category,
    this.isFavorite = false,
    this.visibility = "private",
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'lastUpdated': lastUpdated.toIso8601String(),
      if (description != null) 'description': description,
      if (itemsCount != null) 'itemsCount': itemsCount,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (category != null) 'category': category,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (visibility != null) 'visibility': visibility,
    };
    return json;
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
