class CollectionUIModel {
  final String key;
  final String name;
  final String description;
  final int itemCount;
  final String? imageUrl;

  CollectionUIModel({
    required this.key,
    required this.name,
    required this.description,
    required this.itemCount,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'description': description,
      'itemCount': itemCount,
      'imageUrl': imageUrl,
    };
  }

  factory CollectionUIModel.fromJson(Map<String, dynamic> json) {
    return CollectionUIModel(
      key: json['key'],
      name: json['name'],
      description: json['description'],
      itemCount: json['itemCount'],
      imageUrl: json['imageUrl'],
    );
  }
}
