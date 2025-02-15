# ACCollect

A Flutter application for managing and tracking collections like wine, LEGO, and Funko Pops.  
Built with a **modular architecture** for scalability, maintainability, and separation of concerns.

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

- **Offline Mode** for viewing cached data when offline.
- **Authentication**: profile management.
- **Enhanced UI/UX**: Animated transitions and better navigation.
- **Localization**: Support for multiple languages.
- **Testing**: Unit and Widget tests for better coverage.
- **Light/Dark Mode**: Support for both themes.
- **CD/CI**: Automated testing and deployment.
- **external** sources **: API integration for fetching data from external providers.

---

```plaintext
📁 Firestore Root
 ├── 📁 meta
 │   ├── 📄 categories (Document)
 │       ├── staticCategories: [ "Funko Pop", "LEGO", "Wine", "Other" ] (Array)
 │
 ├── 📁 users
 │   ├── 📄 {userId} (Document)
 │       ├── dynamicCategories: [ "Custom Category 1", "Custom Category 2" ] (Array)
 │       ├── ownedCollections: [ "collectionId1", "collectionId2" ] (Array)
 │
 ├── 📁 collections
 │   ├── 📄 {collectionId} (Document)
 │       ├── name: "My Collection"
 │       ├── ownerId: "userId"
 │       ├── sharedWith: [ "userId2", "userId3" ] (Array)
 │       ├── itemsCount: 5
 │
 ├── 📁 items
 │   ├── 📄 {itemId} (Document)
 │       ├── title: "Iron Man Funko"
 │       ├── category: "Funko Pop"
 │       ├── collectionIds: [ "collectionId1", "collectionId2" ] (Array)
 │       ├── ownerId: "userId"
 │       ├── addedOn: Timestamp
```