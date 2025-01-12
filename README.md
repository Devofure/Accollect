# ACCollect

A Flutter application for managing and tracking collections like wine, LEGO, and Funko Pops. Built
with modular architecture for scalability and maintainability.

## Features

- **Manage Collections**: Create, view, and manage collections.
- **Add Items**: Add new items or associate existing items with collections.
- **Onboarding**: User-friendly onboarding screens.
- **In-Memory Database**: Simulates backend storage for local development and testing.

---

## Folder Structure

```plaintext
lib/
├── core/                       # Core utilities and shared modules
│   ├── data/                   # Shared repositories and in-memory database
│   │   ├── collection_repository.dart
│   │   ├── in_memory_database.dart
│   │   ├── item_repository.dart
│   ├── models/                 # Shared data models
│   │   ├── collection_ui_model.dart
│   │   ├── item_ui_model.dart
│   ├── navigation/             # App-wide navigation setup
│   │   ├── app_router.dart
│   ├── styles/                 # App-wide theme and styles
│   ├── utils/                  # Extensions and constants
│   ├── widgets/                # Reusable widgets
│       ├── collection_tile.dart
│       ├── custom_button.dart
│       ├── empty_state.dart
│       ├── filters.dart
│       ├── item_tile.dart
├── features/                   # Feature-specific modules
│   ├── collection/             # Collection-related features
│   │   ├── collection_screen.dart
│   │   ├── collection_view_model.dart
│   │   ├── create_collection_screen.dart
│   │   ├── create_collection_view_model.dart
│   ├── home/                   # Home screen logic
│   │   ├── home_screen.dart
│   │   ├── home_view_model.dart
│   ├── item/                   # Item-related logic
│   │   ├── add_new_item_screen.dart
│   │   ├── add_or_select_item_screen.dart
│   │   ├── add_or_select_item_view_model.dart
│   │   ├── item_details_screen.dart
│   ├── onboarding/             # Onboarding logic
│       ├── onboarding_screen.dart
├── main.dart                   # Entry point of the app
```

---

## Key Features of the Architecture

1. **Core Module:**
   - Contains reusable components like widgets, data models, and utility functions.
   - Includes an `InMemoryDatabase` for local storage simulation.
   - Shared repositories like `CollectionRepository` and `ItemRepository` reside here.

2. **Feature Modules:**
   - Each feature (e.g., `collection`, `home`, `item`) is self-contained with its screens, view
     models, and other logic.
   - Clear separation ensures features can evolve independently.

3. **Navigation:**
   - Centralized in `app_router.dart` for maintainable route management using `go_router`.

4. **Reusable Components:**
   - Widgets such as `collection_tile.dart`, `item_tile.dart`, and `empty_state.dart` promote UI
     consistency.

---

## How to Run

### Prerequisites

- Install Flutter SDK.
- Run `flutter pub get` to install dependencies.

### Run the App

```bash
flutter run
```

### Run Tests

```bash
flutter test
```

---

## Continuous Integration (CI)

This project uses GitHub Actions for CI. On every push to the `master` branch:

1. The app is analyzed using `flutter analyze`.
2. Tests are executed using `flutter test`.

---

## Future Improvements

- **Persistent Storage:** Replace the `InMemoryDatabase` with Firebase or another backend.
- **Authentication:** Add user login to associate collections with specific users.
- **UI Enhancements:** Introduce animations and transitions for a better user experience.

---

## Examples

### ViewModel Example: `HomeViewModel`

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

### Repository Example: `HomeRepository`

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

### UI Example: `HomeScreen`

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

