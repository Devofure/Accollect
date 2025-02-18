import 'dart:io';

import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/category_attributes_model.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:image_picker/image_picker.dart';

class MultiStepCreateItemViewModel extends ChangeNotifier {
  final ICategoryRepository categoryRepository;
  final IItemRepository itemRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late Command<void, List<String>> fetchCategoriesCommand;
  late Command<void, void> saveItemCommand;

  String? title;
  String? description;
  String selectedCategory = 'Other';
  String? originalPrice;
  String? notes;
  Map<String, dynamic> additionalAttributes = {};

  final List<File> uploadedImages = [];

  MultiStepCreateItemViewModel({
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
        final currentState = formKey.currentState!;
        currentState.save();

        if (title == null || title!.isEmpty) {
          throw Exception('Item title cannot be empty');
        }

        final newItem = ItemUIModel(
          key: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title!,
          description: description ?? '',
          category: selectedCategory,
          addedOn: DateTime.now(),
          imageUrl:
              uploadedImages.isNotEmpty ? uploadedImages.first.path : null,
          collectionKey: null,
          originalPrice: originalPrice,
          notes: notes,
          additionalAttributes:
              additionalAttributes.isNotEmpty ? additionalAttributes : null,
        );
        await itemRepository.createItem(newItem);
      },
      initialValue: null,
    );

    fetchCategoriesCommand.execute();
  }

  Future<CategoryAttributesModel?> getCategoryAttributes() async {
    return categoryRepository.fetchCategoryAttributes(selectedCategory);
  }

  void setTitle(String? value) => title = value;

  void setDescription(String? value) => description = value;

  void setCategory(String? value) {
    if (value != null && value != selectedCategory) {
      selectedCategory = value;
      notifyListeners();
    }
  }

  void setOriginalPrice(String? value) => originalPrice = value;

  void setNotes(String? value) => notes = value;

  void setAdditionalAttribute(String field, dynamic value) {
    if (value != null && value.toString().isNotEmpty) {
      additionalAttributes[field] = value;
    }
  }

  String? validateTitle(String? value) {
    return (value == null || value.isEmpty)
        ? 'Please enter an item name'
        : null;
  }

  void removeImageAt(int index) {
    if (index >= 0 && index < uploadedImages.length) {
      uploadedImages.removeAt(index);
      notifyListeners();
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final movedImage = uploadedImages.removeAt(oldIndex);
    uploadedImages.insert(newIndex, movedImage);
    notifyListeners();
  }

  Future<void> pickImage(int index) async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (index < uploadedImages.length) {
          uploadedImages[index] = File(pickedFile.path);
        } else {
          uploadedImages.add(File(pickedFile.path));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void clearAllImages() {
    uploadedImages.clear();
    notifyListeners();
  }
}
