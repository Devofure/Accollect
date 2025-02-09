import 'package:cloud_firestore/cloud_firestore.dart';

class ItemUIModel {
  final String key;
  final String title;
  final String description;
  final String? collectionName;
  final String category;
  final DateTime addedOn;
  final String? imageUrl;
  final String? collectionKey;

  ItemUIModel({
    required this.key,
    required this.title,
    required this.description,
    required this.category,
    required this.addedOn,
    this.collectionName,
    this.imageUrl,
    this.collectionKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'description': description,
      'category': category,
      'addedOn': Timestamp.fromDate(addedOn),
      'imageUrl': imageUrl,
      'collectionKey': collectionKey,
    };
  }

  factory ItemUIModel.fromJson(Map<String, dynamic> json) {
    return ItemUIModel(
      key: json['key'],
      title: json['title'],
      description: json['description'],
      collectionName: json['collectionName'],
      category: json['category'],
      addedOn: (json['addedOn'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'],
      collectionKey: json['collectionKey'],
    );
  }
}
