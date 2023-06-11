import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:final_project_2023/Pages/view_user_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../navBarTest.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ViewUserProfile', () {
    final MockFirebaseFirestore mockFirestore = MockFirebaseFirestore();
    setUp(() {
      when(mockFirestore.collection('any')).thenReturn(
        // assuming that you have a collection named "users"
        // this returns a document with the given fields
        MockCollectionReference(MockDocumentReference({
          'username': 'test_username',
          'first name': 'John',
          'last name': 'Doe',
          'gender': 'Male',
          'birthDate': '2000-01-01',
          'country': 'USA',
          'description': 'Test description',
          'languages': {'English': 'Fluent'}
        } as Stream<DocumentSnapshot<Map<String, dynamic>>>)),
      );
    });

    testWidgets('displays user profile correctly', (WidgetTester tester) async {
      await Firebase.initializeApp();
      await tester.pumpWidget(MaterialApp(
        home: ViewUserProfile('testUserID'),
      ));

      await tester.pump(); // Pumping to wait for Futures to complete
      expect(find.text('test_username'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('2000-01-01'), findsOneWidget);
      expect(find.text('USA'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Fluent'), findsOneWidget);
    });
  });
}
