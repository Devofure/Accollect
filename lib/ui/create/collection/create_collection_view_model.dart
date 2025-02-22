import 'dart:io';

import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:image_picker/image_picker.dart';

class CreateCollectionViewModel extends ChangeNotifier {
  final ICollectionRepository collectionRepository;
  final ICategoryRepository categoryRepository;
  final ImagePicker _imagePicker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late Command<void, List<String>> fetchCategoriesCommand;
  late Command<void, void> saveCollectionCommand;
  late Command<void, File?> uploadImageCommand;

  String? collectionName;
  String? description;
  String? selectedCategory;
  File? uploadedImage;

  CreateCollectionViewModel({
    required this.collectionRepository,
    required this.categoryRepository,
  }) {
    _setupCommands();
  }

  void _setupCommands() {
    fetchCategoriesCommand = Command.createAsyncNoParam<List<String>>(
      () async {
        final categories = await categoryRepository.fetchAllCategories();
        return categories;
      },
      initialValue: [],
    );

    saveCollectionCommand = Command.createAsyncNoParam<void>(
      () async {
        if (!formKey.currentState!.validate()) {
          return;
        }
        formKey.currentState!.save();
        final newCollection = CollectionUIModel(
          key: DateTime.now().millisecondsSinceEpoch.toString(),
          name: collectionName!,
          description: description,
          itemsCount: 0,
          imageUrl: null,
          lastUpdated: DateTime.now(),
          category: selectedCategory,
        );

        await collectionRepository.createCollection(
            newCollection, uploadedImage);
      },
      initialValue: null,
    );

    uploadImageCommand = Command.createAsyncNoParam<File?>(
      () async {
        final pickedFile =
            await _imagePicker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          uploadedImage = File(pickedFile.path);
          notifyListeners();
        }
        return uploadedImage;
      },
      initialValue: null,
    );

    fetchCategoriesCommand.execute();
  }

  void setCollectionName(String? name) {
    collectionName = name;
  }

  void setDescription(String? desc) {
    description = desc;
  }

  void setCategory(String? selectedCategory) {
    if (selectedCategory != null) {
      this.selectedCategory = selectedCategory;
      notifyListeners();
    }
  }

  String? validateCollectionName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a collection name';
    }
    return null;
  }

  String placeholderAsset(String? category) {
    switch (category) {
      case 'Lego':
        return 'assets/images/category_lego.png';
      case "Funko Pop!":
        return 'assets/images/category_funko_pop.png';
      case "Hot Wheels":
        return 'assets/images/category_hot_wheels.png';
      case "Wine":
        return 'assets/images/category_wine.png';
      default:
        return 'assets/images/category_other.png';
    }
  }
}
