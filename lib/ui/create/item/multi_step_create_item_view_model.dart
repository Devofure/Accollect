import 'dart:async';
import 'dart:io';

import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/data/item_suggestions_repository.dart';
import 'package:accollect/domain/models/category_attributes_model.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:image_picker/image_picker.dart';

class MultiStepCreateItemViewModel extends ChangeNotifier {
  final ICategoryRepository categoryRepository;
  final IItemRepository itemRepository;
  final IItemSuggestionRepository suggestionRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late Command<void, List<String>> fetchCategoriesCommand;
  late Command<void, void> saveItemCommand;
  late Command<String, List<Map<String, dynamic>>> fetchItemByBarcodeCommand;

  String? barcode;
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
    required this.suggestionRepository,
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
          name: title!,
          description: description ?? '',
          category: selectedCategory,
          addedOn: DateTime.now(),
          collectionKey: null,
          originalPrice: originalPrice,
          notes: notes,
          additionalAttributes:
              additionalAttributes.isNotEmpty ? additionalAttributes : null,
        );

        await itemRepository.createItem(newItem, uploadedImages);
      },
      initialValue: null,
    );

    fetchItemByBarcodeCommand =
        Command.createAsync<String, List<Map<String, dynamic>>>(
      suggestionRepository.fetchItemByBarcode,
      initialValue: [],
    );

    fetchCategoriesCommand.execute();
  }

  Future<CategoryAttributesModel?> getCategoryAttributes() async {
    return categoryRepository.fetchCategoryAttributes(selectedCategory);
  }

  void setBarcode(String? value) {
    barcode = value;
    notifyListeners();

    if (barcode != null && barcode!.isNotEmpty) {
      fetchItemByBarcodeCommand.execute(barcode!);
    }
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

  Future<void> pickMultipleImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        uploadedImages.addAll(pickedFiles.map((e) => File(e.path)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> pickImage(int index) async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (index < uploadedImages.length) {
        uploadedImages[index] = file;
      } else {
        uploadedImages.add(file);
      }
      notifyListeners();
    }
  }

  Future<void> scanBarcode() async {
    // Implement barcode scanning functionality here.
    debugPrint("Barcode scanning not implemented yet");
  }

  void selectSuggestion(Map<String, dynamic> suggestion) {
    barcode = suggestion['ean'];
    title = suggestion['title'];
    description = suggestion['description'];
    selectedCategory = suggestion['category'];
    originalPrice = suggestion['originalPrice'];
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  placeholderAsset(String? category) {
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
