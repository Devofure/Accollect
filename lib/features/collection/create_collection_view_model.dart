import 'dart:io';

import 'package:accollect/core/data/collection_repository.dart';
import 'package:accollect/core/models/collection_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateCollectionViewModel extends ChangeNotifier {
  final ICollectionRepository repository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  String? collectionName;
  String? description;
  String category = 'Wine';
  File? uploadedImage;

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

  Future<void> uploadImage() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        uploadedImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<String?> saveCollection() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final newCollection = CollectionUIModel(
        key: DateTime.now().millisecondsSinceEpoch.toString(),
        name: collectionName!,
        description: description ?? '',
        itemCount: 0,
        imageUrl: uploadedImage?.path,
      );

      try {
        await repository.createCollection(newCollection);
        return newCollection.key;
      } catch (e) {
        debugPrint('Failed to save collection: $e');
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
