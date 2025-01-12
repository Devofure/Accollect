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

This document provides guidelines and architectural decisions for the project. The goal is to
maintain consistency, scalability, and readability across the codebase. The architecture used is *
*MVVM (Model-View-ViewModel)** with **Provider** for state management.

---

## Folder Structure

```plaintext
lib/
├── core/                       # Core modules shared across the app
│   ├── navigation/             # Navigation-related files (e.g., AppRouter)
│   ├── utils/                  # Utility extensions or helper classes
│   ├── widgets/                # Reusable widgets (shared across features)
│   └── models/                 # Shared models (e.g., UI models)
├── features/                   # Feature-specific code
│   ├── home/                   # Home feature
│   │   ├── home_screen.dart    # Main Home Screen widget
│   │   ├── home_view_model.dart # ViewModel for Home Screen
│   │   ├── collection_tile.dart # UI Component for a single collection
│   │   ├── latest_item_tile.dart # UI Component for latest items
│   │   └── widgets/            # Feature-specific widgets
│   ├── collection/             # Collection-related features
│   │   ├── create_collection_screen.dart
│   │   ├── collection_model.dart
│   │   ├── collection_repository.dart # Collection data handling
│   │   ├── collection_ui_model.dart   # Collection-specific UI models
│   │   └── local/              # Local data implementations (e.g., mocks)
│   └── auth/                   # Authentication-related features
├── main.dart                   # Entry point of the application
```

---

## Architecture
The app uses **MVVM (Model-View-ViewModel)** to separate concerns and ensure modularity.

### Components

1. **View (UI):**
    - Widgets like `HomeScreen` or `CreateCollectionScreen`.
    - Purely responsible for UI rendering and user interactions.

2. **ViewModel:**
    - Handles state management using `ChangeNotifier`.
    - Responsible for business logic and communicating with repositories.

3. **Model:**
    - Represents domain entities or UI models.

4. **Repository:**
    - Abstracts data handling, whether from local storage, APIs, or Firebase.
    - Provides a clean interface for the ViewModel to fetch data.

---

## Guidelines

### State Management
- Use **Provider** for dependency injection and state management.
- Create a `ChangeNotifier` for each screen or feature that requires state management.
- Avoid business logic in the UI layer; delegate it to ViewModels.

### UI Development
- Keep UI widgets focused and reusable.
- Avoid embedding complex logic in the UI; extract it to ViewModels or separate widgets.
- Structure feature-specific widgets under `widgets/` in their respective feature folder.

### Data Handling
- Use repositories for all data access (e.g., `CollectionRepository`).
- Create interfaces for repositories (e.g., `ICollectionRepository`) to enable mocking and future
  migrations.
- Implement local repositories (e.g., `LocalCollectionRepository`) for testing and development.

---

## Examples

### 1. ViewModel Example: `HomeViewModel`

```dart
import 'package:flutter/foundation.dart';
import 'collection_ui_model.dart';

class HomeViewModel extends ChangeNotifier {
  List<CollectionUIModel> collections = [];
  List<LatestItemUIModel> latestItems = [];
  bool isLoading = true;
  String? errorMessage;

  HomeViewModel() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Simulate data fetching
      await Future.delayed(const Duration(seconds: 2));

      // Mock data
      collections = [
        CollectionUIModel(id: '1', name: 'LEGO', description: 'Build!', itemCount: 5),
      ];

      isLoading = false;
    } catch (e) {
      errorMessage = 'Failed to load data';
      isLoading = false;
    } finally {
      notifyListeners();
    }
  }
}
```

### 2. Repository Example: `CollectionRepository`

```dart
abstract class ICollectionRepository {
  Future<List<CollectionModel>> fetchCollections();
}

class LocalCollectionRepository implements ICollectionRepository {
  @override
  Future<List<CollectionModel>> fetchCollections() async {
    // Mock data
    return Future.delayed(const Duration(seconds: 1), () =>
    [
      CollectionModel(id: '1', name: 'LEGO', description: 'Build!', itemCount: 5),
    ]);
  }
}
```

### 3. UI Example: `HomeScreen`

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                itemCount: viewModel.collections.length,
                itemBuilder: (context, index) {
                  final collection = viewModel.collections[index];
                  return ListTile(
                    title: Text(collection.name),
                  );
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

---

## Summary

This architecture ensures scalability, modularity, and testability while following Flutter
development best practices. By adhering to these guidelines, the project remains maintainable and
easy to extend. If you have questions or need clarification, feel free to ask!

