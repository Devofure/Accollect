import 'package:flutter/material.dart';

import '../../../core/models/collection_ui_model.dart';
import 'data/create_collection_repository.dart';

class CreateCollectionViewModel extends ChangeNotifier {
  final ICreateCollectionRepository repository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? collectionName;
  String? description;
  String category = 'Wine'; // Default category
  String? uploadedImage;

  final List<String> categories = ['Wine', 'LEGO', 'Funko Pop'];

  CreateCollectionViewModel({required this.repository});

  void setCollectionName(String? name) {
    collectionName = name;
  }

  void setDescription(String? desc) {
    description = desc;
  }

  void setCategory(String? selectedCategory) {
    if (selectedCategory != null) {
      category = selectedCategory;
      notifyListeners();
    }
  }

  void uploadImage() {
    uploadedImage = 'https://via.placeholder.com/150'; // Placeholder logic
    notifyListeners();
  }

  Future<String?> saveCollection() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // Create a collection model to send to the repository
      final newCollection = CollectionUIModel(
        key: DateTime.now().millisecondsSinceEpoch.toString(),
        // Example key
        name: collectionName!,
        description: description ?? '',
        itemCount: 0,
        // Initial item count
        imageUrl: uploadedImage,
      );

      try {
        await repository.createCollection(newCollection);
        debugPrint('Collection successfully created: ${newCollection.name}');
        return newCollection.key; // Return the key
      } catch (e) {
        debugPrint('Failed to create collection: $e');
        return null;
      }
    }
    return null;
  }

  String? validateCollectionName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a collection name';
    }
    return null;
  }
}
