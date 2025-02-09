import 'dart:io';

import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:image_picker/image_picker.dart';

class AddNewItemViewModel extends ChangeNotifier {
  final ICategoryRepository categoryRepository;
  final IItemRepository itemRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late Command<void, List<String>> fetchCategoriesCommand;
  late Command<void, void> saveItemCommand;

  String? title;
  String? description;
  String selectedCategory = 'Other';
  File? uploadedImage;

  AddNewItemViewModel({
    required this.categoryRepository,
    required this.itemRepository,
  }) {
    _setupCommands();
  }

  void _setupCommands() {
    fetchCategoriesCommand = Command.createAsyncNoParam<List<String>>(
      categoryRepository.fetchAllCategories,
      initialValue: [],
    );

    saveItemCommand = Command.createAsyncNoParam<void>(
      () async {
        var currentState = formKey.currentState!;
        if (currentState.validate()) {
          currentState.save();
          final newItem = ItemUIModel(
            key: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title!,
            description: description ?? '',
            category: selectedCategory,
            addedOn: DateTime.now(),
            imageUrl: uploadedImage?.path,
            collectionKey: null,
          );
          await itemRepository.createItem(newItem);
        }
      },
      initialValue: null,
    );

    fetchCategoriesCommand.execute();
  }

  Future<void> pickImage() async {
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

  void setTitle(String? value) {
    title = value;
  }

  void setDescription(String? value) {
    description = value;
  }

  void setCategory(String? value) {
    if (value != null) {
      selectedCategory = value;
      notifyListeners();
    }
  }

  String? validateTitle(String? value) {
    return (value == null || value.isEmpty)
        ? 'Please enter an item name'
        : null;
  }
}
