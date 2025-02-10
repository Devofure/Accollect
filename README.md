# ACCollect

A Flutter application for managing and tracking collections like wine, LEGO, and Funko Pops.  
Built with a **modular architecture** for scalability, maintainability, and separation of concerns.

---

## 📌 Features

- **Manage Collections**: Create, view, and manage different collections.
- **Add Items**: Add new items or associate existing items with collections.
- **Category Filtering**: Filter items by category.
- **Onboarding**: A smooth onboarding experience.
- **Stream-based Data Handling**: Efficient use of Firestore streams to reduce unnecessary
  re-fetching.

---

## 📂 Folder Structure

```plaintext
lib/
├── core/                       # Core utilities and shared modules
│   ├── utils/                  # Extensions, helpers, and constants
│   │   ├── app_router.dart      # Centralized navigation management
│   │   ├── app_themes.dart      # Theme and styling definitions
├── data/                        # Data layer (Repositories and Firestore interactions)
├── domain/                      # Business logic layer (Data models, abstraction)
│   ├── models/                  # Defines UI models (Collection, Item)
│       ├── collection_ui_model.dart
│       ├── item_ui_model.dart
├── ui/                          # Presentation layer (Screens & ViewModels)
│   ├── collection/              # Collection-related UI & logic
│   ├── home/                    # Home screen UI & logic
│   ├── item/                    # Item-related UI & logic
│   ├── onboarding/               # Onboarding flow
│   ├── settings/                 # Settings screen
│   ├── widgets/                  # Reusable UI components
│       ├── collection_tile.dart
│       ├── empty_state.dart
│       ├── item_tile_portrait.dart
├── main.dart                     # Entry point of the application
```

---

## 🔥 **Architecture Overview**

The project follows the **MVVM (Model-View-ViewModel)** pattern for a clean separation of concerns.
https://docs.flutter.dev/app-architecture

### **1️⃣ Data Layer (`data/`)**

- Contains **repositories** that interact with Firebase Firestore.
- Uses **Streams** to listen to real-time updates instead of fetching data repeatedly.
- Example:
  ```dart
  Stream<List<ItemUIModel>> fetchItemsStream(String? categoryFilter) {
    Query query = _itemsRef;
    if (categoryFilter != null) {
      query = query.where('category', isEqualTo: categoryFilter);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ItemUIModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }
  ```

### **2️⃣ Domain Layer (`domain/`)**

- Defines **business logic** models (`CollectionUIModel`, `ItemUIModel`).
- Abstracts away the repository interfaces to support dependency injection.

### **3️⃣ Presentation Layer (`ui/`)**

- Contains:
    - **Screens (UI)**
    - **ViewModels (State Management using `flutter_command`)**
    - **Reusable Widgets**
- Uses **Flutter Command** to manage state instead of manually using `notifyListeners()`.

---

## 🚀 **State Management using `flutter_command`**

Instead of `setState()`, the app uses **flutter_command** for **reactive data handling**.

### **Example: Filtering Items by Category**

Instead of managing filters manually, we use **commands**:

```dart
class ItemLibraryViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final ICategoryRepository categoryRepository;

  static const String allCategory = "All";
  late final Command<void, List<String>> fetchCategoriesCommand;
  late final Command<ItemUIModel, void> createItemCommand;
  late final Command<String, void> selectCategoryCommand;

  String? _categoryFilter;
  Stream<List<ItemUIModel>>? _itemsStream;

  ItemLibraryViewModel({required this.categoryRepository, required this.repository}) {
    fetchCategoriesCommand = Command.createAsyncNoParam<List<String>>(
      categoryRepository.fetchAllCategories,
      initialValue: [],
    );
    fetchCategoriesCommand.execute();

    selectCategoryCommand = Command.createSyncNoResult((category) {
      final newFilter = (category == allCategory || category == _categoryFilter)
          ? null
          : category;

      if (_categoryFilter != newFilter) {
        _categoryFilter = newFilter;
        _itemsStream = repository.fetchItemsStream(_categoryFilter);
        notifyListeners();
      }
    });

    _itemsStream = repository.fetchItemsStream(null);
  }

  Stream<List<ItemUIModel>> get itemsStream => _itemsStream!;
}
```

This ensures:
✅ **Live category filtering** without re-fetching everything.  
✅ **Avoids unnecessary `notifyListeners()` calls**.  
✅ **Efficiently updates only when needed**.

---

## 📦 **Libraries Used**

| Package                | Purpose                                     |
|------------------------|---------------------------------------------|
| `flutter_command`      | State management using reactive commands.   |
| `go_router`            | Declarative navigation management.          |
| `provider`             | Dependency injection and ViewModel binding. |
| `intl`                 | Date formatting.                            |
| `cached_network_image` | Optimized image loading with caching.       |

---

## 🛠 **How to Run**

### **Prerequisites**

- Install **Flutter SDK**.
- Run `flutter pub get` to install dependencies.

### **Run the App**
```bash
flutter run
```

### **Run Tests**
```bash
flutter test
```

---

## 🎯 **Future Improvements**

- ✅ **Lazy Loading & Pagination** to handle large collections efficiently.
- ✅ **Offline Mode** for viewing cached data when offline.
- ✅ **Authentication**: User login and profile management.
- ✅ **Enhanced UI/UX**: Animated transitions and better onboarding.

---

## 👥 **Contributing**

We welcome contributions!  
Feel free to submit **issues, PRs, or feature suggestions**.

---

## 📜 **License**

This project is licensed under the **MIT License**.

---

