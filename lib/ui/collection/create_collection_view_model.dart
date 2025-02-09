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
  String? category;
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
        category = categories.firstOrNull;
        return categories;
      },
      initialValue: [],
    );

    saveCollectionCommand = Command.createAsyncNoParam<void>(
      () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          final newCollection = CollectionUIModel(
            key: DateTime.now().millisecondsSinceEpoch.toString(),
            name: collectionName!,
            description: description,
            itemCount: 0,
            imageUrl: uploadedImage?.path,
            lastUpdated: DateTime.now(),
            category: category,
          );
          await collectionRepository.createCollection(newCollection);
        }
      },
      initialValue: null,
    );

    uploadImageCommand = Command.createAsyncNoParam<File?>(
      () async {
        final pickedFile =
            await _imagePicker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          uploadedImage = File(pickedFile.path);
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
      category = selectedCategory;
    }
  }

  String? validateCollectionName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a collection name';
    }
    return null;
  }
}
