# 📦 Accollect – Personal Collection Tracker

_A modern Flutter app to track and manage your collections seamlessly._

## ✨ About the App

Accollect is a Flutter-powered collection management app designed for collectors who want to
efficiently **organize, track, and access** their collections. Whether you're collecting **wine,
Funko Pops, Lego,** or anything else, Accollect helps you stay organized.

## 🚀 Features

✔ **Intuitive Collection Management** – Easily create, edit, and manage different collections.  
✔ **Item Tracking with Details** – Store item details, including images, descriptions, and prices.  
✔ **Stream-based Real-time Updates** – Using Firestore's real-time capabilities.  
✔ **Firebase Integration** – Authentication and Firestore-based data storage.  
✔ **Custom Categories & Attributes** – Organize items with custom categories.

---

## 📂 Project Architecture

The project follows the **MVVM (Model-View-ViewModel) Architecture**, ensuring **separation of
concerns, testability, and scalability.**
Flutter recommendation: https://docs.flutter.dev/app-architecture

### 🛠 Layers:

1. **Domain Layer** (_Pure Dart layer_)
   - Defines **models** (data representations).
   - Provides **abstractions** (repositories & interfaces).

2. **Data Layer** (_Firebase Firestore as the database_)
   - Implements repositories (**Firestore** as the data source).
   - Handles **CRUD operations** for items, collections, and categories.

3. **Presentation Layer** (_Flutter UI_)
   - **ViewModels** (State management using **Provider**).
   - **Widgets** (UI components, responsive designs, and animations).
   - **Navigation** using **GoRouter**.

---

## 📚 Database Structure (Firestore)

Accollect uses **Cloud Firestore** for **real-time data management**. The database is structured as
follows:

```
📦 Firestore Database
 ┣ 📂 users
 ┃ ┣ 📄 {userId} → { displayName, email, dynamicCategories: [list] }
 ┃
 ┣ 📂 collections
 ┃ ┣ 📄 {collectionId} → { name, description, ownerId, itemsCount, imageUrl, sharedWith: [list] }
 ┃
 ┣ 📂 items
 ┃ ┣ 📄 {itemId} → { title, category, imageUrls, collectionIds: [list], ownerId, addedOn }
 ┃
 ┣ 📂 meta
 ┃ ┣ 📄 categories → { staticCategories: [list] }
 ┃
 ┣ 📂 categoryAttributes
 ┃ ┣ 📄 {category} → { customFields: { key: value } }
```

### 📝 Explanation:

- **users** → Stores user information and their custom categories.
- **collections** → Each collection belongs to a user and has an optional **sharedWith** list.
- **items** → Items are linked to **one or more collections** using **collectionIds** (array).
- **meta** → Stores globally available static categories.
- **categoryAttributes** → Stores **custom fields** for each category.

---

## 🛠️ Tech Stack

- **Flutter** (Latest stable version)
- **Dart**
- **Provider** (State management)
- **GoRouter** (Navigation)
- **Firebase** (Authentication, Firestore, Storage)
- **Flutter Command** (Reactive ViewModels)

---

## 📦 Folder Structure

Following **best practices** for **scalability and maintainability**, the folder structure is:

```
📂 lib/
 ┣ 📂 core/              # App-wide utilities & navigation (GoRouter)
 ┣ 📂 data/              # Data layer (Repositories & Firebase integrations)
 ┣ 📂 domain/            # Business logic (Models & Interfaces)
 ┣ 📂 ui/                # Presentation layer (Screens, ViewModels & Widgets)
 ┃ ┣ 📂 widgets/        # Shared UI components (Buttons, Cards, etc.)
 ┃ ┣ 📂 home/           # Home screen & ViewModel
 ┃ ┣ 📂 onboarding/     # Onboarding UI & logic
 ┃ ┣ 📂 collection/     # Collection management UI & ViewModel
 ┃ ┣ 📂 item/           # Item details UI & ViewModel
 ┣ 📂 main.dart         # App entry point
```

---

## 📱 Screenshots

## 🎯 **Future Improvements**

- **Authentication**: profile management.
- **Enhanced UI/UX**: Animated transitions and better navigation.
- **Localization**: Support for multiple languages.
- **Testing**: Unit and Widget tests for better coverage.
- **Light/Dark Mode**: Support for both themes.
- **external** sources **: API integration for fetching data from external providers.