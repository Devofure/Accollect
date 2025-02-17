import 'package:accollect/core/firebase_service.dart';
import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/main.dart';
import 'package:accollect/ui/onboarding/onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'mock_firebase_service.dart';

class MockUser extends Mock implements User {
  @override
  String get uid => 'test_user_id';

  @override
  String get email => 'test@example.com';
}

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class MockCollectionRepository extends Mock implements ICollectionRepository {
  @override
  Stream<List<CollectionUIModel>> fetchCollectionsStream() {
    return Stream.value([
      CollectionUIModel(
        key: 'collection_1',
        name: 'Test Collection',
        category: 'Category A',
        itemsCount: 3,
        description: 'Test Collection Description',
        lastUpdated: DateTime.now(),
      ),
    ]);
  }
}

class MockItemRepository extends Mock implements IItemRepository {}

void main() {
  late MockFirebaseService mockFirebaseService;
  late MockCategoryRepository mockCategoryRepository;
  late MockCollectionRepository mockCollectionRepository;
  late MockItemRepository mockItemRepository;

  setUp(() {
    mockFirebaseService = MockFirebaseService();
    mockCategoryRepository = MockCategoryRepository();
    mockCollectionRepository = MockCollectionRepository();
    mockItemRepository = MockItemRepository();
  });

  Widget createTestApp() {
    return MultiProvider(
      providers: [
        Provider<IFirebaseService>.value(value: mockFirebaseService),
        Provider<ICategoryRepository>.value(value: mockCategoryRepository),
        Provider<ICollectionRepository>.value(value: mockCollectionRepository),
        Provider<IItemRepository>.value(value: mockItemRepository),
      ],
      child: MyApp(firebaseService: mockFirebaseService),
    );
  }

  testWidgets('App starts on onboarding screen when user is not logged in',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
