# Project Guidelines and Architecture

## Table of Contents

1. [Introduction](#introduction)
2. [Folder Structure](#folder-structure)
3. [Architecture](#architecture)
4. [Guidelines](#guidelines)
   - [State Management](#state-management)
   - [UI Development](#ui-development)
   - [Data Handling](#data-handling)
5. [Examples](#examples)

---

## Introduction

This project is a collection management app aimed at helping users organize and track various
collections, such as wines, Funko Pops, and LEGO. The app is built using the **MVVM (
Model-View-ViewModel)** architecture and **Provider** for state management. The design emphasizes
modularity, scalability, and ease of maintenance.

---

## Folder Structure

```plaintext
lib/
├── core/                       # Core modules shared across the app
│   ├── models/                 # Shared UI models
│   │   ├── collection_ui_model.dart
│   │   ├── item_ui_model.dart
│   ├── navigation/             # Navigation-related files
│   │   ├── app_router.dart
│   ├── styles/                 # Theme and styling files
│   │   ├── app_themes.dart
│   ├── utils/                  # Utility extensions and constants
│   │   ├── constants.dart
│   │   ├── extensions.dart
│   ├── widgets/                # Reusable widgets
│       ├── collection_tile.dart
│       ├── custom_button.dart
│       ├── empty_state.dart
│       ├── filters.dart
│       ├── item_tile.dart
├── features/                   # Feature-specific code
│   ├── home/                   # Home feature
│   │   ├── data/               # Data layer for home feature
│   │   │   ├── home_repository.dart
│   │   ├── home_screen.dart    # Main Home Screen widget
│   │   ├── home_view_model.dart # ViewModel for Home Screen
│   ├── collection/             # Collection-related features
│   │   ├── create_collection_screen.dart
│   │   ├── collection_ui_model.dart
│   │   ├── collection_repository.dart
│   ├── auth/                   # Authentication-related features
│   ├── onboarding/             # Onboarding screens
│   ├── settings/               # Settings feature
├── main.dart                   # Entry point of the application
```

---

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture to ensure a clean separation of
concerns. Each feature includes its own View, ViewModel, and Repository.

### Components

1. **View (UI):**
   - Widgets like `HomeScreen` or `CollectionScreen`.
   - Responsible for rendering the UI and handling user interactions.

2. **ViewModel:**
   - Manages the state of the UI using `ChangeNotifier`.
   - Handles business logic and communicates with the Repository.

3. **Model:**
   - Represents UI data or domain entities (e.g., `CollectionUIModel`).

4. **Repository:**
   - Abstracts data handling, whether from local storage, APIs, or Firebase.
   - Provides a clean interface for ViewModels to fetch data.

---

## Guidelines

### State Management

- Use **Provider** for dependency injection and state management.
- Each feature should have its own `ChangeNotifier` for managing state.
- Avoid business logic in the UI layer; delegate it to the ViewModel.

### UI Development

- Keep UI widgets focused and reusable.
- Place reusable widgets in `core/widgets/` and feature-specific widgets in
  `features/{feature_name}/widgets/`.
- Avoid embedding logic in UI components.

### Data Handling

- Use repositories for all data access.
- Define repository interfaces (e.g., `IHomeRepository`) for flexibility and testing.
- Implement local repositories (e.g., `LocalHomeRepository`) for mock data during development.

---

## Examples

### 1. ViewModel Example: `HomeViewModel`

```dart
import 'package:flutter/foundation.dart';
import 'collection_ui_model.dart';
import 'data/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
   final IHomeRepository repository;

   List<CollectionUIModel> collections = [];
   List<ItemUIModel> latestItems = [];
  bool isLoading = true;
  String? errorMessage;

   HomeViewModel({required this.repository}) {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
       isLoading = true;
       errorMessage = null;
       notifyListeners();

       collections = await repository.fetchCollections();
       latestItems = await repository.fetchLatestItems();
      isLoading = false;
    } catch (e) {
      errorMessage = 'Failed to load data';
      isLoading = false;
    } finally {
      notifyListeners();
    }
  }

   void retryFetchingData() {
      _loadData();
   }
}
```

### 2. Repository Example: `HomeRepository`

```dart
import 'package:accollect/core/models/collection_ui_model.dart';
import 'package:accollect/core/models/item_ui_model.dart';

abstract class IHomeRepository {
   Future<List<CollectionUIModel>> fetchCollections();

   Future<List<ItemUIModel>> fetchLatestItems();
}

class HomeRepository implements IHomeRepository {
  @override
  Future<List<CollectionUIModel>> fetchCollections() async {
     return Future.delayed(
        const Duration(seconds: 1),
                () =>
        [
           CollectionUIModel(
              key: '1',
              name: 'LEGO',
              description: 'Build your imagination!',
              itemCount: 5,
              imageUrl: '',
           ),
           CollectionUIModel(
              key: '2',
              name: 'Wines',
              description: 'Fine collection of wines.',
              itemCount: 10,
              imageUrl: '',
           ),
        ],
     );
  }

  @override
  Future<List<ItemUIModel>> fetchLatestItems() async {
     return Future.delayed(
        const Duration(seconds: 1),
                () =>
        [
           ItemUIModel(
              key: 'item1',
              title: 'Super Guy',
              imageUrl: null,
              addedOn: DateTime.now(),
              description: '',
           ),
           ItemUIModel(
              key: 'item2',
              title: 'Mega Hero',
              imageUrl: null,
              addedOn: DateTime.now().subtract(const Duration(days: 1)),
              description: '',
           ),
        ],
     );
  }
}
```

### 3. UI Example: `HomeScreen`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_view_model.dart';
import 'data/home_repository.dart';
import '../../core/widgets/collection_tile.dart';
import '../../core/widgets/item_tile.dart';

class HomeScreen extends StatelessWidget {
   final IHomeRepository repository;

   const HomeScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
       create: (_) => HomeViewModel(repository: repository),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.errorMessage != null) {
                 return Center(
                    child: Text(
                       viewModel.errorMessage!,
                       style: const TextStyle(color: Colors.white),
                    ),
                 );
              }

              final collections = viewModel.collections;
              final latestItems = viewModel.latestItems;

              return ListView.builder(
                 itemCount: collections.length,
                itemBuilder: (context, index) {
                   return CollectionTile(collection: collections[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
```

